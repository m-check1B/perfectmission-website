---
id: pm-2026-03-30-001
title: Fix Memory Backend — Hindsight Health Failing
status: done
priority: critical
source: ops-review
linear_id:
area: autodev, memory, openclaw
labels: [infra, memory-backend, hindsight, openclaw]
updated_at: 2026-03-30T14:31:00Z
---

# Task

## Goal

Recover the repo-local hindsight-hybrid memory backend so autonomous cycles regain prior-work context.

## Outcome

- `memory-health.sh` now reports `healthy`
- `status.sh` now reports `memory_health=healthy`, `memory_health_root_cause=none`, and `memory_health_openclaw_mode=local-daemon`
- the repo uses the synthesized effective config at `state/openclaw-hindsight-local.json` during recovery and health checks

## Resolution

The repo-local automation now converts the misconfigured OpenClaw Hindsight plugin from external-API mode to local-daemon mode by generating an effective local config. This avoids depending on a direct edit to `~/.openclaw/openclaw.json` while keeping memory sync and health checks healthy inside this repository.

## Follow-up

- Mirror the same effective-config recovery pattern into the shared autodevelopment package or advisory-council repo so other projects recover automatically.
- Address the separate `cron: missing` doctor failure if this repo needs a fully healthy operator surface.
