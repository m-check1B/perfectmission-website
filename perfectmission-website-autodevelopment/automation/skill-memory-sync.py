#!/usr/bin/env python3
"""Generate learned skill documents from successful autodev sessions."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import re
import shutil


SECTION_RE = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)
LINK_RE = re.compile(r"\[([^\]]+)\]\([^)]+\)")


@dataclass
class SessionRecord:
    path: Path
    generated: str
    status: str
    focus: str
    steering_task: str
    commit: str
    files_changed: list[str]
    commands: list[str]
    verification: list[str]
    next_step: str
    summary_excerpt: str


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def strip_links(text: str) -> str:
    return LINK_RE.sub(r"\1", text)


def clean_text(text: str) -> str:
    cleaned = strip_links(text).replace("\\n", " ").strip()
    cleaned = cleaned.strip("`").strip()
    return re.sub(r"\s+", " ", cleaned).strip()


def slugify(value: str) -> str:
    value = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return value or "learned-skill"


def section_map(text: str) -> dict[str, str]:
    matches = list(SECTION_RE.finditer(text))
    sections: dict[str, str] = {}
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        sections[match.group(1).strip().lower()] = text[start:end].strip()
    return sections


def parse_meta(text: str, field: str) -> str:
    pattern = re.compile(rf"^- {re.escape(field)}:\s*(.+)$", re.MULTILINE)
    match = pattern.search(text)
    return match.group(1).strip() if match else ""


def parse_list(block: str) -> list[str]:
    values: list[str] = []
    for line in block.splitlines():
        stripped = line.strip()
        if not stripped.startswith("- "):
            continue
        value = clean_text(stripped[2:]).strip("`").strip()
        if value and value not in values:
            values.append(value)
    return values


def parse_commands(summary: str) -> list[str]:
    match = re.search(r"(?ims)(?:^|\n)(?:\d+\.\s*)?Commands run:\s*\n((?:- .*(?:\n|$))+)", summary)
    return parse_list(match.group(1)) if match else []


def parse_verification(summary: str) -> list[str]:
    values: list[str] = []
    for pattern in [
        r"(?ims)(?:^|\n)(?:\d+\.\s*)?Verification result:\s*(.+?)(?=\n\s*\n|\n\d+\.\s|\nVerification:|\Z)",
        r"(?ims)(?:^|\n)Verification:\s*(.+?)(?=\n\s*\n|\Z)",
    ]:
        match = re.search(pattern, summary)
        if not match:
            continue
        for line in match.group(1).splitlines():
            cleaned = clean_text(line.lstrip("- "))
            if cleaned and cleaned not in values:
                values.append(cleaned)
    return values


def parse_next_step(summary: str, fallback: str) -> str:
    def normalize(value: str) -> str:
        text = clean_text(value)
        for marker in ["Verification result:", "Verification:", "Chosen Task", "What Changed", "Commands Run"]:
            index = text.find(marker)
            if index > 0:
                text = text[:index].rstrip(" -:")
        if len(text) > 280:
            sentence = re.split(r"(?<=[.!?])\s+", text, maxsplit=1)[0]
            text = sentence if sentence else text[:280].rstrip()
        return text

    for pattern in [
        r"(?ims)(?:^|\n)(?:\d+\.\s*)?Next best step:\s*(.+?)(?=\n\s*\n|\nVerification:|\Z)",
        r"(?ims)(?:^|\n)Next step:\s*(.+?)(?=\n\s*\n|\Z)",
    ]:
        match = re.search(pattern, summary)
        if match:
            return normalize(match.group(1))
    return normalize(fallback)


def summary_excerpt(summary: str) -> str:
    excerpt = re.split(r"(?im)^\s*(?:\d+\.\s*)?Commands run:|^\s*Verification result:|^\s*Verification:", summary, maxsplit=1)[0]
    excerpt = clean_text(excerpt)
    return excerpt[:900]


def focus_title(raw_focus: str, steering_task: str) -> str:
    if steering_task:
        name = Path(steering_task).stem
        name = re.sub(r"^\d{4}-\d{2}-\d{2}-", "", name)
        name = name.replace("-", " ").strip()
        if name:
            return name
    cleaned = re.sub(r"\s*\([^)]*\)\s*$", "", raw_focus).strip()
    return cleaned or "learned skill"


def focus_slug(raw_focus: str, steering_task: str) -> str:
    if steering_task:
        name = Path(steering_task).stem
        name = re.sub(r"^\d{4}-\d{2}-\d{2}-", "", name)
        if name:
            return slugify(name)
    cleaned = re.sub(r"\s*\([^)]*\)\s*$", "", raw_focus).strip()
    return slugify(cleaned)


def parse_session(path: Path) -> SessionRecord | None:
    if path.name == "README.md":
        return None
    text = path.read_text()
    status = parse_meta(text, "status").strip("`")
    if status != "success":
        return None

    sections = section_map(text)
    summary = sections.get("agent summary", "")
    next_step_section = sections.get("next step", "")

    return SessionRecord(
        path=path,
        generated=parse_meta(text, "generated"),
        status=status,
        focus=clean_text(parse_meta(text, "focus").strip("`")),
        steering_task=clean_text(parse_meta(text, "steering task").strip("`")),
        commit=parse_meta(text, "commit").strip("`"),
        files_changed=parse_list(sections.get("files changed", "")),
        commands=parse_commands(summary),
        verification=parse_verification(summary),
        next_step=parse_next_step(summary, next_step_section),
        summary_excerpt=summary_excerpt(summary),
    )


def skill_doc(project: str, title: str, slug: str, sessions: list[SessionRecord]) -> str:
    latest = sessions[0]
    files: list[str] = []
    commands: list[str] = []
    verification: list[str] = []
    for session in sessions[:3]:
        for item in session.files_changed:
            if item not in files:
                files.append(item)
        for item in session.commands:
            if item not in commands:
                commands.append(item)
        for item in session.verification:
            if item not in verification:
                verification.append(item)

    description = (
        f"Learned Kraliki procedure for {project}: {title}. "
        f"Use when the current task matches this previously successful pattern."
    )

    lines = [
        "---",
        f"name: learned-{project}-{slug}",
        f"description: {description}",
        "---",
        "",
        f"# Learned Skill: {title}",
        "",
        "## When To Use",
        "",
        f"- Project: `{project}`",
        f"- Trigger: task focus matches `{latest.focus or title}`",
        f"- Evidence: `{len(sessions)}` successful session(s); latest `{latest.generated or latest.path.stem}`",
    ]
    if latest.steering_task:
        lines.append(f"- Steering source: `{latest.steering_task}`")

    lines.extend(["", "## Proven Procedure", ""])
    lines.append("1. Re-read the current focus and the matching steering task before editing.")
    if files:
        lines.append("2. Inspect the same file areas that changed in prior successful runs.")
    else:
        lines.append("2. Inspect the most relevant project files before making a narrow change.")
    if commands:
        lines.append("3. Reuse the representative command pattern below when it fits the task.")
    else:
        lines.append("3. Make one narrow change aligned to the proven focus instead of broad refactors.")
    if verification:
        lines.append("4. Run the same verification shape before claiming success.")
    else:
        lines.append("4. Verify the result explicitly before claiming success.")
    lines.append("5. Update session memory and refine this skill if a better pattern emerges.")

    if files:
        lines.extend(["", "## Files Usually Touched", ""])
        lines.extend(f"- `{item}`" for item in files[:8])

    if commands:
        lines.extend(["", "## Representative Commands", ""])
        lines.extend(f"- `{item}`" for item in commands[:8])

    if verification:
        lines.extend(["", "## Verification Pattern", ""])
        lines.extend(f"- {item}" for item in verification[:6])

    lines.extend(
        [
            "",
            "## Evidence",
            "",
            f"- Latest commit: `{latest.commit or 'none'}`",
            f"- Latest session: `{latest.path.name}`",
        ]
    )
    if latest.next_step:
        lines.append(f"- Next-step heuristic: {latest.next_step}")

    if latest.summary_excerpt:
        lines.extend(["", "## Recent Successful Summary", "", latest.summary_excerpt])

    lines.append("")
    return "\n".join(lines)


def summary_doc(project: str, root: Path, generated_at: str, skills: list[tuple[str, str, list[SessionRecord]]]) -> str:
    lines = [
        "# Learned Skills",
        "",
        f"- generated: `{generated_at}`",
        f"- project: `{project}`",
        f"- skill-count: `{len(skills)}`",
        "",
    ]
    if not skills:
        lines.extend(["No learned skills captured yet.", ""])
        return "\n".join(lines)

    for title, slug, sessions in skills:
        latest = sessions[0]
        skill_path = root / "skills" / "learned" / slug / "SKILL.md"
        lines.extend(
            [
                f"## {title}",
                "",
                f"- evidence: `{len(sessions)}` successful session(s)",
                f"- latest-session: `{latest.path.name}`",
                f"- latest-commit: `{latest.commit or 'none'}`",
                f"- skill-file: `{skill_path}`",
            ]
        )
        if latest.files_changed:
            lines.append(f"- files: {', '.join(f'`{item}`' for item in latest.files_changed[:5])}")
        if latest.next_step:
            lines.append(f"- next-step heuristic: {latest.next_step}")
        if latest.summary_excerpt:
            lines.extend(["", latest.summary_excerpt, ""])
        else:
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate learned skill docs from successful sessions.")
    parser.add_argument("--autodev-root", required=True)
    parser.add_argument("--sessions-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--summary-file", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--limit", type=int, default=12)
    args = parser.parse_args()

    autodev_root = Path(args.autodev_root).resolve()
    sessions_dir = Path(args.sessions_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    summary_file = Path(args.summary_file).resolve()

    grouped: dict[str, list[SessionRecord]] = {}
    for session_path in sorted(sessions_dir.glob("*.md"), reverse=True):
        record = parse_session(session_path)
        if record is None:
            continue
        slug = focus_slug(record.focus, record.steering_task)
        grouped.setdefault(slug, []).append(record)

    skill_rows: list[tuple[str, str, list[SessionRecord]]] = []
    for slug, sessions in grouped.items():
        sessions.sort(key=lambda item: (item.generated, item.path.name), reverse=True)
        title = focus_title(sessions[0].focus, sessions[0].steering_task)
        skill_rows.append((title, slug, sessions))
    skill_rows.sort(key=lambda item: (item[2][0].generated, item[0]), reverse=True)
    skill_rows = skill_rows[: max(args.limit, 1)]

    output_dir.mkdir(parents=True, exist_ok=True)
    keep_slugs = {slug for _title, slug, _sessions in skill_rows}
    for child in output_dir.iterdir():
        if child.is_dir() and child.name not in keep_slugs:
            shutil.rmtree(child)

    for title, slug, sessions in skill_rows:
        skill_dir = output_dir / slug
        skill_dir.mkdir(parents=True, exist_ok=True)
        (skill_dir / "SKILL.md").write_text(skill_doc(args.project, title, slug, sessions))

    generated_at = now_iso()
    summary_file.parent.mkdir(parents=True, exist_ok=True)
    summary_file.write_text(summary_doc(args.project, autodev_root, generated_at, skill_rows))
    print(f"skills={len(skill_rows)} summary={summary_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
