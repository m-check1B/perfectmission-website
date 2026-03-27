# Steering

Local-first steering for the repo-local autodevelopment package.

This directory is the operator-facing control surface for task selection.
Treat it as canonical even when a remote tracker like Linear is available.

Rules:

- place the highest-priority ready task in `active/` when you want the next cycles to stay on it
- place candidate tasks in `inbox/` when they are ready but not yet promoted
- move completed items to `done/`
- move stale or superseded items to `archive/`
- use `providers/linear/` only as a sync adapter state area, not as the source of truth

The automation reads `active/` first, then `inbox/`, and only falls back to `queue/TODO.md` when no steering task exists.
