# Fix Stale Memory Health Check

**Priority:** P1
**Created:** 2026-03-31
**Status:** inbox

## Problem

Doctor reports `degraded` because `memory-health: stale (>70m)`. The memory health check last ran 813 minutes ago (over 13 hours). While product cycles are still succeeding, the stale health check degrades doctor status and could mask real issues.

## Expected Behavior

Memory health check should run within the configured heartbeat interval. The `memory-health-status.txt` and `memory-health-latest.txt` files should be refreshed at least every 60-90 minutes.

## Steps

1. Check `automation/memory-health.sh` (or equivalent) exists and is scheduled
2. Verify cron block includes memory-health job
3. If missing, add memory-health to the cron schedule
4. If present but failing, check logs for errors
5. After fix, confirm doctor shows `healthy`

## Verification

- `doctor-latest.txt` shows `memory-health: ok` or `healthy` with timestamp <90m old
- Doctor overall status returns to `healthy`
