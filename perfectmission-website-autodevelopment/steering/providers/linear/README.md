# Linear Adapter State

This directory is reserved for optional Linear sync state.

Local steering files stay canonical.
Linear is treated as a mirror, inbox, or export target when configured.

Expected runtime files:

- `map.json`
  - local task ID to Linear issue mapping
- `last-sync.json`
  - timestamp and status of the latest sync attempt
- `outbox.jsonl`
  - queued outbound mutations when Linear is unavailable
- `mirror/`
  - optional mirrored issue snapshots
