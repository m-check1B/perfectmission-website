---
id: pm-2026-03-31-force-push
title: Force push all pending commits to origin — fix push:ahead:4
status: active
priority: critical
source: ops-review
linear_id:
area: perfectmission-website-autodevelopment
labels: [ops, git, deployment, blocker]
created_at: 2026-03-31T08:36:00Z
---

# Task

## Goal
Push the 4 commits that are ahead of origin to the remote, fixing the `push:ahead:4` doctor status. This has been degrading since at least 2026-03-30 and the existing task `2026-03-30-fix-push-ahead.md` hasn't resolved it.

## Context
- Doctor reports: `degraded`, `push:ahead:4`
- Previous task `2026-03-30-fix-push-ahead.md` created when ahead:3 — now worsened to ahead:4
- Auto-push reports success each cycle but commits don't reach origin
- Live site is missing accessibility fixes from all 4 commits
- This is blocking the doctor from reporting healthy

## Action
1. `git status --short --branch` to confirm current branch and ahead count
2. `git log --oneline @{u}..HEAD` to see which commits are ahead
3. `git push origin HEAD:main` (or appropriate branch) — force the push
4. If push fails, capture the error (auth, branch protection, remote rejected)
5. If auth issue: document and escalate to Matej
6. Verify with `git fetch origin && git rev-parse HEAD FETCH_HEAD` — should match
7. Move `2026-03-30-fix-push-ahead.md` from `steering/active/` to `steering/done/`

## Verification
- Doctor next run shows `push: clean`
- `git rev-parse HEAD` == `git rev-parse origin/main`
- Live site reflects latest accessibility fixes
