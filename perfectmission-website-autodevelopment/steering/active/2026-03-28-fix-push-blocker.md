---
id: pm-2026-03-28-002
title: Fix git push blocker — clean non-autodev state and push safely
status: inbox
priority: critical
source: local
linear_id:
area: git, deployment
labels: [fix, git, push, blocker]
updated_at: 2026-03-28T16:04:00Z
---

# Task

## Goal

Fix the git push blocker so autodev cycles can push commits again. The repo is ahead of origin by 1 commit (ed5252d PNG social preview), and there are unstaged changes in `perfectmission-website-autodevelopment/` internal files that are blocking push.

## Context

Doctor reports: "push: ahead-unsafe:2 — push: blocked by non-autodev pending commits"

`git status` shows:
- Branch is 1 commit ahead of origin/main
- Unstaged changes: `perfectmission-website-autodevelopment/automation/__pycache__/hindsight_bridge.cpython-314.pyc` and `perfectmission-website-autodevelopment/memory/semantic/project-map.md`
- The pyc file should be gitignored. The memory file may need committing.

## Steps

1. Add `*.pyc` to `.gitignore` if not already there and remove tracked pyc files
2. Either commit or restore the `memory/semantic/project-map.md` change
3. Push the pending commit(s) to origin/main
4. Verify doctor shows clean push status

## Acceptance

- `git status` shows clean working tree
- All local commits are pushed to origin/main
- Autodev doctor reports healthy push status
