#!/usr/bin/env python3
"""Build a hybrid local memory backend for repo-local autodevelopment packages."""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
from shutil import which
from typing import Iterable


ENTITY_RE = re.compile(r"\b[A-Za-z][A-Za-z0-9_./:-]{2,}\b")
FRONTMATTER_RE = re.compile(r"(?s)^---\n(.*?)\n---\n?")
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


@dataclass
class MemoryItem:
    item_id: str
    item_type: str
    scope: str
    title: str
    summary: str
    details: str
    path: str
    source: str
    bucket: str
    entities: list[str]
    tags: list[str]
    created_at: str
    updated_at: str
    last_validated_at: str
    confidence: float
    durability: str
    content_hash: str


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def file_timestamp(path: Path) -> str:
    return datetime.fromtimestamp(path.stat().st_mtime, timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def slugify(value: str) -> str:
    value = re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-")
    return value or "item"


def parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}, text

    payload: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        payload[key.strip()] = value.strip().strip('"').strip("'")
    return payload, text[match.end():].lstrip()


def first_heading(body: str) -> str:
    for line in body.splitlines():
        stripped = line.strip()
        if stripped.startswith("# "):
            return stripped[2:].strip()
    return ""


def extract_entities(*chunks: str) -> list[str]:
    counter: Counter[str] = Counter()
    for chunk in chunks:
        for match in ENTITY_RE.findall(chunk):
            token = match.strip("`").lower()
            if len(token) < 3 or token in STOPWORDS:
                continue
            counter[token] += 1
    return [token for token, _count in counter.most_common(18)]


def summarize_text(body: str) -> str:
    lines = [line.strip() for line in body.splitlines() if line.strip()]
    if not lines:
        return ""
    for line in lines:
        if line.startswith("#"):
            continue
        return line[:280]
    return lines[0][:280]


def read_markdown_item(path: Path, autodev_root: Path, item_type: str, source: str, bucket: str, scope: str, durability: str, confidence: float) -> MemoryItem:
    text = path.read_text()
    frontmatter, body = parse_frontmatter(text)
    title = frontmatter.get("title") or first_heading(body) or path.stem.replace("-", " ")
    updated_at = frontmatter.get("updated_at") or file_timestamp(path)
    created_at = frontmatter.get("created_at") or updated_at
    linear_id = frontmatter.get("linear_id", "")
    tags = [tag for tag in re.split(r"[,\s]+", frontmatter.get("labels", "")) if tag and tag not in {"[", "]"}]
    entities = extract_entities(title, body, linear_id, path.as_posix())
    summary = summarize_text(body) or title
    details = body.strip()
    item_id = frontmatter.get("id") or f"{item_type}-{slugify(path.stem)}"
    content_hash = hashlib.sha256(text.encode()).hexdigest()

    return MemoryItem(
        item_id=item_id,
        item_type=item_type,
        scope=scope,
        title=title,
        summary=summary,
        details=details,
        path=str(path.relative_to(autodev_root)),
        source=source,
        bucket=bucket,
        entities=entities,
        tags=tags,
        created_at=created_at,
        updated_at=updated_at,
        last_validated_at=now_iso(),
        confidence=confidence,
        durability=durability,
        content_hash=content_hash,
    )


def read_context_file(path: Path, autodev_root: Path, project_root: Path) -> MemoryItem:
    text = path.read_text()
    rel = path.relative_to(project_root)
    title = rel.as_posix()
    summary = summarize_text(text)
    entities = extract_entities(title, summary, text)
    return MemoryItem(
        item_id=f"context-{slugify(rel.as_posix())}",
        item_type="context_doc",
        scope=rel.parts[0] if rel.parts else ".",
        title=title,
        summary=summary,
        details=text.strip(),
        path=str(rel),
        source="repo-context",
        bucket="context",
        entities=entities,
        tags=[],
        created_at=file_timestamp(path),
        updated_at=file_timestamp(path),
        last_validated_at=now_iso(),
        confidence=0.92,
        durability="medium",
        content_hash=hashlib.sha256(text.encode()).hexdigest(),
    )


def gather_items(autodev_root: Path, project_root: Path, context_files: list[str]) -> list[MemoryItem]:
    items: list[MemoryItem] = []

    mapping: list[tuple[Path, str, str, str, str, float]] = [
        (autodev_root / "memory" / "curated" / "OBJECTIVE.md", "objective", "curated", "curated", "high", 0.98),
        (autodev_root / "memory" / "curated" / "PROJECT.md", "project_brief", "curated", "curated", "high", 0.97),
        (autodev_root / "memory" / "curated" / "MEMORY.md", "operator_memory", "curated", "curated", "medium", 0.92),
        (autodev_root / "memory" / "semantic" / "project-map.md", "project_map", "semantic", "semantic", "high", 0.96),
        (autodev_root / "memory" / "semantic" / "architecture.md", "architecture", "semantic", "semantic", "high", 0.96),
        (autodev_root / "memory" / "semantic" / "invariants.md", "invariant", "semantic", "semantic", "high", 0.99),
        (autodev_root / "memory" / "semantic" / "commands.md", "command", "semantic", "semantic", "medium", 0.95),
        (autodev_root / "memory" / "semantic" / "ownership.md", "ownership", "semantic", "semantic", "medium", 0.9),
        (autodev_root / "memory" / "episodic" / "decisions.md", "decision", "episodic", "episodic", "medium", 0.87),
        (autodev_root / "memory" / "episodic" / "failures.md", "failure", "episodic", "episodic", "medium", 0.91),
        (autodev_root / "memory" / "episodic" / "changelog.md", "changelog", "episodic", "episodic", "medium", 0.84),
        (autodev_root / "memory" / "active" / "current-task.md", "working_memory", "active", "active", "low", 0.88),
        (autodev_root / "memory" / "active" / "open-questions.md", "working_memory", "active", "active", "low", 0.82),
        (autodev_root / "memory" / "active" / "next-actions.md", "working_memory", "active", "active", "low", 0.82),
        (autodev_root / "steering" / "board.md", "task_board", "steering", "steering", "medium", 0.93),
        (autodev_root / "queue" / "TODO.md", "queue", "queue", "queue", "medium", 0.86),
    ]

    for path, item_type, source, bucket, durability, confidence in mapping:
        if path.is_file():
            items.append(read_markdown_item(path, autodev_root, item_type, source, bucket, path.parent.name, durability, confidence))

    task_dirs = [
        (autodev_root / "steering" / "active", "active"),
        (autodev_root / "steering" / "inbox", "inbox"),
        (autodev_root / "steering" / "done", "done"),
        (autodev_root / "steering" / "archive", "archive"),
    ]
    for directory, bucket in task_dirs:
        if not directory.is_dir():
            continue
        for path in sorted(directory.glob("*.md")):
            if path.name == "README.md":
                continue
            items.append(read_markdown_item(path, autodev_root, "task", "steering", bucket, bucket, "medium", 0.94))

    session_dir = autodev_root / "memory" / "episodic" / "sessions"
    if session_dir.is_dir():
        for path in sorted(session_dir.glob("*.md")):
            if path.name == "README.md":
                continue
            items.append(read_markdown_item(path, autodev_root, "session_summary", "episodic", "sessions", "sessions", "low", 0.8))

    mirror_dir = autodev_root / "steering" / "providers" / "linear" / "mirror"
    if mirror_dir.is_dir():
        for path in sorted(mirror_dir.glob("*.md")):
            if path.name == "README.md":
                continue
            items.append(read_markdown_item(path, autodev_root, "tracker_mirror", "linear-mirror", "linear-mirror", "tracker", "low", 0.78))

    for context_entry in context_files:
        candidate = project_root / context_entry
        if candidate.is_file():
            items.append(read_context_file(candidate, autodev_root, project_root))

    return items


def init_db(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS items (
          item_id TEXT PRIMARY KEY,
          item_type TEXT NOT NULL,
          scope TEXT NOT NULL,
          title TEXT NOT NULL,
          summary TEXT NOT NULL,
          details TEXT NOT NULL,
          path TEXT NOT NULL,
          source TEXT NOT NULL,
          bucket TEXT NOT NULL,
          entities_json TEXT NOT NULL,
          tags_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          last_validated_at TEXT NOT NULL,
          confidence REAL NOT NULL,
          durability TEXT NOT NULL,
          content_hash TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE VIRTUAL TABLE IF NOT EXISTS items_fts USING fts5(
          item_id UNINDEXED,
          content
        )
        """
    )
    return conn


def write_index(conn: sqlite3.Connection, items: list[MemoryItem]) -> None:
    conn.execute("DELETE FROM items")
    conn.execute("DELETE FROM items_fts")
    for item in items:
        conn.execute(
            """
            INSERT INTO items (
              item_id, item_type, scope, title, summary, details, path, source, bucket,
              entities_json, tags_json, created_at, updated_at, last_validated_at,
              confidence, durability, content_hash
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                item.item_id,
                item.item_type,
                item.scope,
                item.title,
                item.summary,
                item.details,
                item.path,
                item.source,
                item.bucket,
                json.dumps(item.entities),
                json.dumps(item.tags),
                item.created_at,
                item.updated_at,
                item.last_validated_at,
                item.confidence,
                item.durability,
                item.content_hash,
            ),
        )
        fts_content = " ".join([item.title, item.summary, item.details, " ".join(item.entities), item.path, item.scope])
        conn.execute("INSERT INTO items_fts (item_id, content) VALUES (?, ?)", (item.item_id, fts_content))
    conn.commit()


def write_graph(graph_path: Path, items: list[MemoryItem]) -> dict[str, object]:
    entity_counts: Counter[str] = Counter()
    edge_counts: Counter[tuple[str, str]] = Counter()
    for item in items:
        unique_entities = []
        seen: set[str] = set()
        for entity in item.entities:
            if entity in seen:
                continue
            seen.add(entity)
            unique_entities.append(entity)
            entity_counts[entity] += 1
        for index, left in enumerate(unique_entities[:10]):
            for right in unique_entities[index + 1 : 10]:
                pair = tuple(sorted((left, right)))
                edge_counts[pair] += 1

    graph_payload = {
        "generated_at": now_iso(),
        "entity_count": len(entity_counts),
        "top_entities": [{"entity": entity, "count": count} for entity, count in entity_counts.most_common(50)],
        "edges": [{"left": left, "right": right, "weight": weight} for (left, right), weight in edge_counts.most_common(100)],
    }
    graph_path.parent.mkdir(parents=True, exist_ok=True)
    graph_path.write_text(json.dumps(graph_payload, indent=2) + "\n")
    return graph_payload


def write_run_summaries(path: Path, items: Iterable[MemoryItem]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with path.open("w") as handle:
        for item in items:
            if item.item_type != "session_summary":
                continue
            handle.write(
                json.dumps(
                    {
                        "id": item.item_id,
                        "title": item.title,
                        "summary": item.summary,
                        "updated_at": item.updated_at,
                        "path": item.path,
                        "scope": item.scope,
                    }
                )
                + "\n"
            )
            count += 1
    return count


def parse_context_files(raw: str) -> list[str]:
    return [entry for entry in raw.split() if entry]


def detect_mgrep_status(use_mgrep: str, store: str) -> dict[str, str]:
    installed = "yes" if which("mgrep") else "no"
    auth_source = "missing"

    if use_mgrep == "false":
        status = "disabled"
    elif installed != "yes":
        status = "requested-missing" if use_mgrep == "true" else "missing"
    else:
        if os.environ.get("MXBAI_API_KEY"):
            auth_source = "api-key"
        elif Path.home().joinpath(".mgrep", "token.json").is_file():
            auth_source = "token"

        if auth_source != "missing":
            status = "ready"
        else:
            status = "requested-auth-missing" if use_mgrep == "true" else "installed-auth-missing"

    return {
        "mgrep_available": status,
        "mgrep_installed": installed,
        "mgrep_auth": auth_source,
        "mgrep_store": store,
    }


def detect_rg_status(use_rg: str) -> dict[str, str]:
    installed = "yes" if which("rg") else "no"
    if use_rg == "false":
        available = "disabled"
    elif installed == "yes":
        available = "ready"
    else:
        available = "requested-missing" if use_rg == "true" else "missing"
    return {
        "rg_available": available,
        "rg_installed": installed,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a hybrid local memory backend for repo-local autodevelopment")
    parser.add_argument("--autodev-root", required=True)
    parser.add_argument("--project-root", required=True)
    parser.add_argument("--context-files", default="")
    parser.add_argument("--output-status", required=True)
    parser.add_argument("--db-path", required=True)
    parser.add_argument("--graph-path", required=True)
    parser.add_argument("--run-summaries", required=True)
    parser.add_argument("--use-rg", default="true")
    parser.add_argument("--use-mgrep", default="auto")
    parser.add_argument("--mgrep-store", default="mgrep")
    args = parser.parse_args()

    autodev_root = Path(args.autodev_root).resolve()
    project_root = Path(args.project_root).resolve()
    output_status = Path(args.output_status).resolve()
    db_path = Path(args.db_path).resolve()
    graph_path = Path(args.graph_path).resolve()
    run_summaries_path = Path(args.run_summaries).resolve()
    context_files = parse_context_files(args.context_files)

    items = gather_items(autodev_root, project_root, context_files)
    conn = init_db(db_path)
    try:
        write_index(conn, items)
    finally:
        conn.close()

    graph_payload = write_graph(graph_path, items)
    run_summary_count = write_run_summaries(run_summaries_path, items)
    item_types = Counter(item.item_type for item in items)

    mgrep_status = detect_mgrep_status(args.use_mgrep, args.mgrep_store)
    rg_status = detect_rg_status(args.use_rg)

    status_payload = {
        "backend": "hybrid-sqlite",
        "status": "ok",
        "indexed_at": now_iso(),
        "indexed_count": len(items),
        "item_types": dict(item_types),
        "db_path": str(db_path),
        "graph_path": str(graph_path),
        "run_summaries_path": str(run_summaries_path),
        "graph_entities": graph_payload["entity_count"],
        "run_summary_count": run_summary_count,
        "query_source": "sqlite-fts+symbolic",
        **rg_status,
        **mgrep_status,
    }

    output_status.parent.mkdir(parents=True, exist_ok=True)
    output_status.write_text(json.dumps(status_payload, indent=2) + "\n")
    print(json.dumps(status_payload))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
