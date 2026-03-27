# Steering Board

Use this file for a compact operator view of the current local backlog.

## Current Priorities

- Promote the next ready task into `steering/active/` when you want cycles to stay on it.

## Rules

- `steering/active/` wins over `steering/inbox/`.
- `steering/inbox/` wins over `queue/TODO.md`.
- Keep one task per markdown file.
- Prefer stable IDs in frontmatter so a remote tracker can mirror cleanly later.

## Sync Policy

- local steering files are canonical
- remote trackers are adapters
- conflicts should be preserved and surfaced, not auto-resolved silently
