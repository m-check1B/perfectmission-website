#!/usr/bin/env python3
"""Retrieve relevant memory items from the hybrid local memory backend."""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sqlite3
import subprocess
from typing import Any

from hindsight_bridge import HindsightError, bank_path, hindsight_request, load_autodev_config


TOKEN_RE = re.compile(r"\b[A-Za-z][A-Za-z0-9_./:-]{2,}\b")
STOPWORDS = {
    "the",
    "and",
    "for",
    "with",
    "this",
    "that",
    "from",
    "into",
    "only",
    "when",
    "then",
    "else",
    "none",
    "true",
    "false",
    "task",
    "goal",
    "next",
    "file",
    "files",
    "readme",
    "memory",
    "status",
    "project",
}
TYPE_BOOST = {
    "invariant": 0.25,
    "architecture": 0.2,
    "project_map": 0.18,
    "command": 0.16,
    "failure": 0.18,
    "decision": 0.14,
    "task": 0.15,
    "working_memory": 0.08,
    "session_summary": 0.1,
    "objective": 0.16,
    "project_brief": 0.14,
    "operator_memory": 0.12,
    "context_doc": 0.08,
    "queue": 0.06,
    "learned_skill": 0.2,
}


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def parse_time(value: str) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError:
        return None


def tokenize(text: str) -> list[str]:
    return [token.lower() for token in TOKEN_RE.findall(text)]


def sanitize_fts_query(query: str) -> str:
    tokens = [token for token in re.findall(r"[A-Za-z0-9_]{2,}", query.lower()) if token]
    if not tokens:
        return "memory"
    return " ".join(dict.fromkeys(tokens))


def query_terms(text: str) -> list[str]:
    terms: list[str] = []
    for token in tokenize(text):
        normalized = token.strip().lower()
        normalized = re.sub(r"[^a-z0-9_]+", "", normalized)
        if len(normalized) < 3 or normalized in STOPWORDS:
            continue
        if normalized not in terms:
            terms.append(normalized)
    return terms[:6]


def path_overlap_score(path: str, query_tokens: set[str]) -> float:
    path_tokens = {token for token in re.split(r"[^A-Za-z0-9]+", path.lower()) if token}
    if not path_tokens or not query_tokens:
        return 0.0
    return len(path_tokens & query_tokens) / max(len(path_tokens), 1)


def entity_overlap_score(entities: list[str], query_tokens: set[str]) -> float:
    if not entities or not query_tokens:
        return 0.0
    entity_tokens = set(entities)
    return len(entity_tokens & query_tokens) / max(len(entity_tokens), 1)


def recency_score(updated_at: str) -> float:
    parsed = parse_time(updated_at)
    if parsed is None:
        return 0.0
    age_hours = max((now_utc() - parsed).total_seconds() / 3600, 0.0)
    if age_hours < 6:
        return 1.0
    if age_hours < 24:
        return 0.8
    if age_hours < 72:
        return 0.55
    return 0.25


def fts_candidates(conn: sqlite3.Connection, query: str, limit: int) -> list[dict[str, Any]]:
    rows = conn.execute(
        """
        SELECT
          items.item_id,
          items.item_type,
          items.scope,
          items.title,
          items.summary,
          items.details,
          items.path,
          items.source,
          items.bucket,
          items.entities_json,
          items.tags_json,
          items.updated_at,
          items.last_validated_at,
          items.confidence,
          items.durability,
          bm25(items_fts) AS rank
        FROM items_fts
        JOIN items ON items.item_id = items_fts.item_id
        WHERE items_fts MATCH ?
        ORDER BY rank
        LIMIT ?
        """,
        (query or "memory", limit),
    ).fetchall()
    columns = [
        "item_id",
        "item_type",
        "scope",
        "title",
        "summary",
        "details",
        "path",
        "source",
        "bucket",
        "entities_json",
        "tags_json",
        "updated_at",
        "last_validated_at",
        "confidence",
        "durability",
        "rank",
    ]
    candidates = []
    for row in rows:
        payload = dict(zip(columns, row))
        payload["entities"] = json.loads(payload.pop("entities_json"))
        payload["tags"] = json.loads(payload.pop("tags_json"))
        candidates.append(payload)
    if candidates:
        return candidates

    fallback_rows = conn.execute(
        """
        SELECT
          item_id, item_type, scope, title, summary, details, path, source, bucket,
          entities_json, tags_json, updated_at, last_validated_at, confidence, durability
        FROM items
        ORDER BY updated_at DESC
        LIMIT ?
        """,
        (limit,),
    ).fetchall()
    columns = [
        "item_id",
        "item_type",
        "scope",
        "title",
        "summary",
        "details",
        "path",
        "source",
        "bucket",
        "entities_json",
        "tags_json",
        "updated_at",
        "last_validated_at",
        "confidence",
        "durability",
    ]
    result = []
    for row in fallback_rows:
        payload = dict(zip(columns, row))
        payload["entities"] = json.loads(payload.pop("entities_json"))
        payload["tags"] = json.loads(payload.pop("tags_json"))
        payload["rank"] = 10.0
        result.append(payload)
    return result


def score_candidate(candidate: dict[str, Any], query_tokens: set[str]) -> float:
    semantic = max(0.0, 1.0 / (1.0 + float(candidate.get("rank", 10.0))))
    path_score = path_overlap_score(candidate["path"], query_tokens)
    entity_score = entity_overlap_score(candidate["entities"], query_tokens)
    recency = recency_score(candidate["updated_at"])
    type_boost = TYPE_BOOST.get(candidate["item_type"], 0.05)
    verification = float(candidate.get("confidence", 0.5))
    return (
        0.35 * semantic
        + 0.25 * path_score
        + 0.15 * entity_score
        + 0.10 * recency
        + 0.10 * type_boost
        + 0.05 * verification
    )


def parse_bool(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


def run_mgrep(project_root: Path, query: str, store: str, sync: bool, max_count: int, max_file_size: int, max_file_count: int) -> list[str]:
    command = ["mgrep"]
    if store:
        command.extend(["--store", store])
    command.extend(["search", "-m", str(max_count), "-c"])
    if sync:
        command.append("-s")
    command.extend(
        [
            "--max-file-size",
            str(max_file_size),
            "--max-file-count",
            str(max_file_count),
            query,
            str(project_root),
        ]
    )
    env = os.environ.copy()
    if store:
        env["MXBAI_STORE"] = store
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
            env=env,
        )
    except Exception:
        return []
    if result.returncode != 0:
        return []
    lines = [line.rstrip() for line in result.stdout.splitlines() if line.strip()]
    return lines[:12]


def run_rg(project_root: Path, autodev_root: Path, query: str, max_matches: int) -> list[str]:
    terms = query_terms(query)
    if not terms:
        return []

    excludes: list[str] = []
    try:
        relative_autodev = autodev_root.resolve().relative_to(project_root.resolve()).as_posix()
    except ValueError:
        relative_autodev = ""
    if relative_autodev:
        excludes.extend(["-g", f"!{relative_autodev}/**"])

    results: list[str] = []
    seen: set[str] = set()
    per_term_limit = max(2, min(4, max_matches))

    for term in terms:
        command = [
            "rg",
            "-n",
            "--smart-case",
            "-S",
            "--max-count",
            str(per_term_limit),
            *excludes,
            term,
            str(project_root),
        ]
        try:
            run = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=8,
                check=False,
            )
        except Exception:
            continue
        if run.returncode not in (0, 1):
            continue
        for line in run.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                rel = Path(line.split(":", 1)[0]).resolve().relative_to(project_root.resolve()).as_posix()
                formatted = f"{rel}:{line.split(':', 1)[1]}"
            except Exception:
                formatted = line
            if formatted in seen:
                continue
            seen.add(formatted)
            results.append(formatted)
            if len(results) >= max_matches:
                return results
    return results


def recall_hindsight(query: str, limit: int) -> tuple[list[dict[str, Any]], str | None]:
    config = load_autodev_config()
    if not config.enabled:
        return [], None
    payload = {
        "query": query,
        "types": ["world", "experience", "observation"],
        "budget": config.recall_budget,
        "max_tokens": config.recall_max_tokens,
        "include": {"entities": {"max_tokens": 300}},
    }
    try:
        response = hindsight_request(
            config,
            "POST",
            f"{bank_path(config.bank_id)}/memories/recall",
            payload,
        )
    except HindsightError as exc:
        return [], str(exc)
    results = response.get("results", [])
    if not isinstance(results, list):
        return [], None
    return results[:limit], None


def render_markdown(
    query: str,
    status_payload: dict[str, Any],
    hindsight_items: list[dict[str, Any]],
    hindsight_error: str | None,
    top_items: list[dict[str, Any]],
    rg_lines: list[str],
    mgrep_lines: list[str],
) -> str:
    hindsight_status = status_payload.get("hindsight") if isinstance(status_payload.get("hindsight"), dict) else {}
    lines = [
        "# Memory Retrieval",
        "",
        f"- query: `{query}`",
        f"- backend: `{status_payload.get('backend', 'hybrid-sqlite')}`",
        f"- indexed items: `{status_payload.get('indexed_count', 0)}`",
        f"- query source: `{status_payload.get('query_source', 'sqlite-fts+symbolic')}`",
        f"- rg: `{status_payload.get('rg_available', 'missing')}`",
        f"- mgrep: `{status_payload.get('mgrep_available', 'missing')}`",
        f"- mgrep auth: `{status_payload.get('mgrep_auth', 'missing')}`",
        f"- mgrep store: `{status_payload.get('mgrep_store', 'mgrep')}`",
        f"- hindsight bank: `{hindsight_status.get('bank_id', 'disabled')}`",
        f"- hindsight status: `{hindsight_status.get('status', 'disabled')}`",
        "",
        "## Hindsight Recall",
        "",
    ]

    if hindsight_error:
        lines.append(f"- error: `{hindsight_error}`")
    elif not hindsight_items:
        lines.append("- none")
    else:
        for index, item in enumerate(hindsight_items, start=1):
            metadata = item.get("metadata") or {}
            path = metadata.get("path") or item.get("document_id") or "unknown"
            tags = item.get("tags") or []
            entities = item.get("entities") or []
            lines.extend(
                [
                    f"### {index}. {item.get('text', '').strip()[:120] or 'memory'}",
                    "",
                    f"- type: `{item.get('type', 'unknown')}`",
                    f"- path: `{path}`",
                    f"- context: `{item.get('context') or 'none'}`",
                    f"- mentioned: `{item.get('mentioned_at') or 'unknown'}`",
                    f"- tags: {', '.join(tags[:8]) if tags else 'none'}",
                    f"- entities: {', '.join(entities[:8]) if entities else 'none'}",
                    "",
                    item.get("text", "- no memory text"),
                    "",
                ]
            )

    lines.extend(["## Local Indexed Memory", ""])

    if not top_items:
        lines.append("- none")
    else:
        for index, item in enumerate(top_items, start=1):
            lines.extend(
                [
                    f"### {index}. {item['title']}",
                    "",
                    f"- type: `{item['item_type']}`",
                    f"- path: `{item['path']}`",
                    f"- source: `{item['source']}`",
                    f"- updated: `{item['updated_at']}`",
                    f"- score: `{item['score']:.3f}`",
                    f"- entities: {', '.join(item['entities'][:8]) if item['entities'] else 'none'}",
                    "",
                    item["summary"] or "- no summary",
                    "",
                ]
            )

    if rg_lines:
        lines.extend(["## Local Code Hints (rg)", ""])
        lines.extend(f"- `{line}`" for line in rg_lines)
        lines.append("")

    if mgrep_lines:
        lines.extend(["## Optional mgrep Hints", ""])
        lines.extend(f"- `{line}`" for line in mgrep_lines)
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Retrieve relevant memory items from the hybrid backend")
    parser.add_argument("--autodev-root", required=True)
    parser.add_argument("--db-path", required=True)
    parser.add_argument("--status-file", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--project-root", required=True)
    parser.add_argument("--query", required=True)
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--use-rg", default="true")
    parser.add_argument("--rg-max-matches", type=int, default=12)
    parser.add_argument("--use-mgrep", default="auto")
    parser.add_argument("--mgrep-store", default="mgrep")
    parser.add_argument("--mgrep-sync", default="true")
    parser.add_argument("--mgrep-max-count", type=int, default=8)
    parser.add_argument("--mgrep-max-file-size", type=int, default=5242880)
    parser.add_argument("--mgrep-max-file-count", type=int, default=5000)
    args = parser.parse_args()

    db_path = Path(args.db_path).resolve()
    output_path = Path(args.output).resolve()
    status_path = Path(args.status_file).resolve()
    project_root = Path(args.project_root).resolve()
    autodev_root = Path(args.autodev_root).resolve()

    status_payload = json.loads(status_path.read_text()) if status_path.is_file() else {"backend": "hybrid-sqlite"}
    status_payload["query_source"] = "sqlite-fts+symbolic"
    hindsight_items, hindsight_error = recall_hindsight(args.query, args.limit)
    if hindsight_items:
        status_payload["query_source"] = "hindsight+sqlite-fts+symbolic"

    top_items: list[dict[str, Any]] = []
    if db_path.is_file():
        conn = sqlite3.connect(db_path)
        try:
            candidates = fts_candidates(conn, sanitize_fts_query(args.query), max(args.limit * 3, 12))
        finally:
            conn.close()

        query_tokens = set(tokenize(args.query))
        scored = []
        for candidate in candidates:
            candidate["score"] = score_candidate(candidate, query_tokens)
            scored.append(candidate)
        scored.sort(key=lambda item: item["score"], reverse=True)
        top_items = scored[: args.limit]

    rg_lines: list[str] = []
    if args.use_rg == "true" or (args.use_rg == "auto" and status_payload.get("rg_available") == "ready"):
        rg_lines = run_rg(project_root, autodev_root, args.query, args.rg_max_matches)
        if rg_lines:
            status_payload["query_source"] = f"{status_payload.get('query_source', 'sqlite-fts+symbolic')}+rg"

    mgrep_lines: list[str] = []
    if status_payload.get("mgrep_available") == "ready":
        mgrep_lines = run_mgrep(
            project_root,
            args.query,
            args.mgrep_store,
            parse_bool(args.mgrep_sync),
            args.mgrep_max_count,
            args.mgrep_max_file_size,
            args.mgrep_max_file_count,
        )
        if mgrep_lines:
            status_payload["query_source"] = f"{status_payload.get('query_source', 'sqlite-fts+symbolic')}+mgrep"

    status_path.parent.mkdir(parents=True, exist_ok=True)
    status_path.write_text(json.dumps(status_payload, indent=2) + "\n")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        render_markdown(
            args.query,
            status_payload,
            hindsight_items,
            hindsight_error,
            top_items,
            rg_lines,
            mgrep_lines,
        )
    )
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
