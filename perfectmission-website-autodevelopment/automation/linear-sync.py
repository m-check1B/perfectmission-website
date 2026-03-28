#!/usr/bin/env python3
"""Bidirectional Linear sync for repo-local autodevelopment steering."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen

LINEAR_API_URL = "https://api.linear.app/graphql"
LINEAR_API_KEY = os.environ.get("LINEAR_API_KEY", "")
DEFAULT_TEAM_KEY = os.environ.get("LINEAR_TEAM_KEY", "").upper()
DEFAULT_TEAM_ID = os.environ.get("LINEAR_TEAM_ID", "")

STATE_TYPE_TO_BUCKET = {
    "started": "active",
    "unstarted": "inbox",
    "backlog": "inbox",
    "triage": "inbox",
    "completed": "done",
    "cancelled": "archive",
    "canceled": "archive",
}


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def slugify(value: str) -> str:
    return re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-") or "task"


def parse_frontmatter(text: str) -> dict[str, str]:
    match = re.match(r"(?s)^---\n(.*?)\n---\n?", text)
    if not match:
        return {}
    frontmatter: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        frontmatter[key.strip()] = value.strip().strip('"').strip("'")
    return frontmatter


def gql(query: str, variables: dict | None = None) -> dict:
    payload = json.dumps({"query": query, "variables": variables or {}}).encode()
    req = Request(
        LINEAR_API_URL,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": LINEAR_API_KEY,
        },
    )
    try:
        with urlopen(req, timeout=30) as response:
            data = json.loads(response.read())
    except URLError as exc:
        return {"errors": [{"message": f"network error: {exc}"}]}

    return data


def resolve_team_id() -> str | None:
    if DEFAULT_TEAM_ID:
        return DEFAULT_TEAM_ID
    if not DEFAULT_TEAM_KEY:
        return None

    query = """
    query {
      teams {
        nodes {
          id
          key
          name
        }
      }
    }
    """
    data = gql(query)
    for node in data.get("data", {}).get("teams", {}).get("nodes", []):
        if (node.get("key") or "").upper() == DEFAULT_TEAM_KEY:
            return node.get("id")
    return None


def issue_to_mirror_md(issue: dict) -> tuple[str, str]:
    identifier = issue["identifier"]
    title = issue["title"]
    state_name = issue.get("state", {}).get("name", "Inbox")
    priority = issue.get("priority", 0)
    description = issue.get("description", "") or ""
    url = issue.get("url", "")
    updated = issue.get("updatedAt", now_iso())

    frontmatter = [
        "---",
        f"linear_id: {identifier}",
        f"title: {title}",
        f"status: {state_name.lower()}",
        f"priority: {priority_name(priority).lower()}",
        "source: linear-mirror",
        f"linear_url: {url}",
        f"updated_at: {updated}",
        "---",
        "",
    ]

    body = f"# {title}\n\n"
    if description:
        body += f"{description}\n"
    body += f"\n---\n*Synced from Linear [{identifier}]({url})*\n"

    return f"{slugify(identifier)}.md", "\n".join(frontmatter) + body


def priority_name(priority: int) -> str:
    return {
        0: "No priority",
        1: "Urgent",
        2: "High",
        3: "Medium",
        4: "Low",
    }.get(priority, "No priority")


def fetch_issues(team_id: str, updated_after: str | None = None) -> list[dict]:
    issues: list[dict] = []
    cursor: str | None = None

    while True:
        after_clause = ", after: $after" if cursor else ""
        query = f"""
        query($teamId: String!, $updatedAfter: DateTime, $after: String) {{
          issues(
            filter: {{
              team: {{ id: {{ eq: $teamId }} }}
              updatedAt: {{ gte: $updatedAfter }}
            }}
            first: 50
            orderBy: updatedAt
            {after_clause}
          ) {{
            pageInfo {{ hasNextPage endCursor }}
            nodes {{
              identifier
              title
              priority
              url
              description
              updatedAt
              state {{ name type }}
              assignee {{ name }}
            }}
          }}
        }}
        """
        variables = {
            "teamId": team_id,
            "updatedAfter": updated_after,
            "after": cursor,
        }
        data = gql(query, variables)
        nodes = data.get("data", {}).get("issues", {}).get("nodes", [])
        issues.extend(nodes)

        page_info = data.get("data", {}).get("issues", {}).get("pageInfo", {})
        if not page_info.get("hasNextPage"):
            break
        cursor = page_info.get("endCursor")

    return issues


def resolve_issue_id(identifier: str, team_id: str) -> str | None:
    parts = identifier.split("-", 1)
    if len(parts) != 2 or not parts[1].isdigit():
        return identifier

    query = """
    query($teamId: String!, $number: Float!) {
      issues(
        filter: {
          team: { id: { eq: $teamId } }
          number: { eq: $number }
        }
        first: 1
      ) {
        nodes {
          id
          identifier
        }
      }
    }
    """
    data = gql(query, {"teamId": team_id, "number": float(parts[1])})
    nodes = data.get("data", {}).get("issues", {}).get("nodes", [])
    if not nodes:
        return None
    return nodes[0].get("id")


def fetch_team_states(team_id: str) -> list[dict]:
    query = """
    query($teamId: String!) {
      team(id: $teamId) {
        states {
          nodes {
            id
            name
            type
          }
        }
      }
    }
    """
    data = gql(query, {"teamId": team_id})
    return data.get("data", {}).get("team", {}).get("states", {}).get("nodes", [])


def classify_bucket_from_state_name(name: str) -> str:
    normalized = name.lower()
    if normalized in {"done", "completed", "resolved", "accepted"}:
        return "done"
    if normalized in {"cancelled", "canceled"}:
        return "archive"
    if normalized in {"in progress", "started", "doing", "in review"}:
        return "active"
    if normalized in {"backlog", "icebox"}:
        return "inbox"
    return "inbox"


def resolve_state_id(states: list[dict], bucket: str) -> str | None:
    for state in states:
        state_type = (state.get("type") or "").lower()
        if STATE_TYPE_TO_BUCKET.get(state_type) == bucket:
            return state.get("id")
    for state in states:
        if classify_bucket_from_state_name(state.get("name") or "") == bucket:
            return state.get("id")
    return None


def cmd_pull(autodev_root: Path) -> dict:
    if not LINEAR_API_KEY:
        return {"status": "skipped", "reason": "LINEAR_API_KEY not set"}

    team_id = resolve_team_id()
    if not team_id:
        return {"status": "skipped", "reason": "LINEAR_TEAM_ID or LINEAR_TEAM_KEY not set"}

    mirror_dir = autodev_root / "steering" / "providers" / "linear" / "mirror"
    last_sync_path = autodev_root / "steering" / "providers" / "linear" / "last-sync.json"
    mirror_dir.mkdir(parents=True, exist_ok=True)

    updated_after = None
    if last_sync_path.exists():
        try:
            last_sync = json.loads(last_sync_path.read_text())
            if last_sync.get("status") in {"ok", "local-only"}:
                updated_after = last_sync.get("synced_at")
        except json.JSONDecodeError:
            updated_after = None

    issues = fetch_issues(team_id, updated_after)
    if not issues and updated_after:
        issues = fetch_issues(team_id, None)

    written = 0
    for issue in issues:
        filename, content = issue_to_mirror_md(issue)
        target = mirror_dir / filename
        existing_frontmatter = {}
        if target.exists():
            existing_frontmatter = parse_frontmatter(target.read_text())
        if existing_frontmatter.get("updated_at") == issue.get("updatedAt"):
            continue
        target.write_text(content)
        written += 1

    return {
        "status": "ok",
        "team_id": team_id,
        "synced_at": now_iso(),
        "fetched": len(issues),
        "written": written,
        "mirror_total": len(list(mirror_dir.glob("*.md"))),
    }


def cmd_push(autodev_root: Path) -> dict:
    if not LINEAR_API_KEY:
        return {"status": "skipped", "reason": "LINEAR_API_KEY not set"}

    team_id = resolve_team_id()
    if not team_id:
        return {"status": "skipped", "reason": "LINEAR_TEAM_ID or LINEAR_TEAM_KEY not set"}

    outbox_path = autodev_root / "steering" / "providers" / "linear" / "outbox.jsonl"
    if not outbox_path.exists() or outbox_path.stat().st_size == 0:
        return {"status": "ok", "pushed": 0, "message": "outbox empty"}

    states = fetch_team_states(team_id)
    pushed = 0
    errors = 0
    remaining: list[str] = []

    for raw_line in outbox_path.read_text().splitlines():
        line = raw_line.strip()
        if not line:
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            continue

        linear_id = record.get("linear_id", "")
        if not linear_id:
            remaining.append(line)
            continue

        issue_uuid = resolve_issue_id(linear_id, team_id)
        if not issue_uuid:
            errors += 1
            remaining.append(line)
            continue

        update_input: dict[str, str] = {}
        target_state_id = resolve_state_id(states, record.get("bucket", "inbox"))
        if target_state_id:
            update_input["stateId"] = target_state_id
        if record.get("title"):
            update_input["title"] = record["title"]

        if not update_input:
            pushed += 1
            continue

        mutation = """
        mutation($id: String!, $input: IssueUpdateInput!) {
          issueUpdate(id: $id, input: $input) {
            success
            issue {
              identifier
              state { name type }
            }
          }
        }
        """
        data = gql(mutation, {"id": issue_uuid, "input": update_input})
        success = data.get("data", {}).get("issueUpdate", {}).get("success")
        if success:
            pushed += 1
        else:
            errors += 1
            remaining.append(line)

    outbox_path.write_text("\n".join(remaining) + ("\n" if remaining else ""))
    return {
        "status": "ok" if errors == 0 else "partial",
        "team_id": team_id,
        "synced_at": now_iso(),
        "pushed": pushed,
        "errors": errors,
        "remaining": len(remaining),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Linear sync for repo-local autodevelopment steering")
    parser.add_argument("action", choices=["pull", "push", "sync"])
    parser.add_argument("--autodev-root", required=True, type=Path)
    args = parser.parse_args()

    if args.action == "pull":
        print(json.dumps(cmd_pull(args.autodev_root)))
        return 0

    if args.action == "push":
        print(json.dumps(cmd_push(args.autodev_root)))
        return 0

    combined = {
        "pull": cmd_pull(args.autodev_root),
        "push": cmd_push(args.autodev_root),
    }
    print(json.dumps(combined))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
