---
id: pm-2026-03-31-001
title: Fix stale memory-health check (doctor shows degraded)
status: inbox
priority: medium
source: axis-ops
linear_id:
area: perfectmission-website-autodevelopment
labels: [ops, memory, automation, doctor]
created_at: 2026-03-31T03:36:00Z
---

# Task

## Goal
Fix the stale `memory-health` check that causes doctor to report `degraded` status for perfectmission-website.

## Context
- Doctor reports `degraded` solely due to `memory-health: stale (>70m)`
- Last `memory-health-latest.txt` was generated at 2026-03-30T14:33 UTC (~13h stale)
- Hindsight API at `http://127.0.0.1:9077/health` is reachable and healthy
- `memory-health-openclaw-mode: local-daemon` — the check mechanism is the issue, not the backend
- Cycles are running fine — this is a monitoring issue, not a functional one

## Task
1. Check what triggers the memory-health check (cron/scheduler)
2. Manually run the health check to see if it passes now
3. If the cron is missing or misconfigured, fix it
4. Verify doctor returns to `healthy` status

## Constraints
- Don't break existing cycle behavior
- Cycles are productive — this is housekeeping

## Success criteria
- `doctor-status.txt` reports `healthy`
- `memory-sync` age is <70 minutes
