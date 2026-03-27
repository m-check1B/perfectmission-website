---
name: autodev-instance-ops
description: Operate this repo-local autodevelopment package and use its structured memory correctly. Use this when working inside the target repository with the local automation package, whether the agent is unattended or manually started.
---

# Autodevelopment Instance Ops

This skill belongs to one repo-local autodevelopment package.

Use it to:
- treat local `steering/` as the canonical task-control surface
- read the package memory in the correct order
- understand the local automation contract
- keep manual agent work aligned with unattended cycles
- update memory without turning it into noisy diary sludge

## Read Order

### 1. Steering and stable task framing
- `steering/board.md`
- selected task in `steering/active/` or `steering/inbox/`, when present
- `memory/curated/OBJECTIVE.md`
- `memory/curated/PROJECT.md`
- `memory/curated/MEMORY.md`

### 2. Durable semantic memory
- `memory/semantic/project-map.md`
- `memory/semantic/invariants.md`
- `memory/semantic/architecture.md`
- `memory/semantic/commands.md`
- `memory/semantic/ownership.md`

### 3. Episodic memory
- `memory/episodic/failures.md`
- `memory/episodic/decisions.md`
- `memory/episodic/changelog.md`
- newest files in `memory/episodic/sessions/`

### 4. Working memory
- `memory/active/current-task.md`
- `memory/active/open-questions.md`
- `memory/active/next-actions.md`

## Rules

- Keep policy in curated files and skill text, not in episodic notes.
- Treat `steering/` as task control, not as semantic memory.
- Promote durable truths into `memory/semantic/`.
- Promote attempts, failures, and decisions into `memory/episodic/`.
- Keep `memory/active/` short and overwrite it aggressively.
- Do not turn raw command output into first-class memory.
- Prefer evidence-backed memory over speculation.

## Useful Local Commands

- `automation/status.sh`
- `automation/stats.sh`
- `automation/steering-sync.sh`
- `automation/verify.sh`
- `rg -n --smart-case "<query>" "<path>"`
- `mgrep --store "$AUTODEV_MEMORY_MGREP_STORE" search -s "<query>" "<path>"`
- `automation/memory-backend-index.py`
- `automation/memory-backend-retrieve.py`
- `automation/doctor.sh`
- `automation/remediator.sh`
- `automation/memory-sync.sh`
- `automation/cycle.sh`

## Safe Manual Workflow

1. Check `automation/status.sh`
2. If needed, pause the package from the dashboard or set `AUTODEV_ENABLED=false`
3. Read steering, semantic, episodic, and active memory in the order above
4. Do one narrow task
5. Run `automation/verify.sh` when test hooks are configured
6. Update the relevant memory surfaces before handing control back

## Memory Write Policy

- `semantic/`: only facts likely to remain true
- `episodic/`: decisions, failures, and run summaries
- `active/`: immediate next context only

## Retrieval Notes

- Treat the package backend as canonical memory.
- Local `rg` retrieval is the default low-cost code recall layer.
- Use `mgrep` only as a retrieval accelerator when `automation/status.sh` reports:
  - `memory_backend_mgrep=ready`
  - `memory_backend_mgrep_auth=api-key` or `token`
- Keep `mgrep` scoped to the package store for this repository, not a shared catch-all store.
- When `AUTODEV_TEST_COMMAND` or `AUTODEV_VISUAL_TEST_COMMAND` are configured, treat them as the final local proof gate before unattended progress is considered trustworthy.
