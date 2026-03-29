# perfectmission-website Autodevelopment

Repo-local automation package for unattended development work on `perfectmission-website`.

This is the primary `open-kraliki` deployment surface for per-repository automation.
Use the centralized launchd control plane from the root repository only when you explicitly want one shared Linear + Telegram + watchdog stack outside the target repository.

This package is:

- repo-owned instead of home-directory owned
- cron-driven instead of app-specific automation driven
- adapter-based instead of locked to one CLI or model
- isolated, so one package can run per repository in parallel with others
- scoped to the configured `PROJECT_ROOT`, even when that project lives inside a larger git repository

If you want one shared control plane with Linear intake, sequential fixers, commit + push, Telegram relay, heartbeat, and watchdog, go back to the root docs and use the centralized launchd path instead.

## Layout

```text
perfectmission-website-autodevelopment/
├── .env.example
├── automation/
│   ├── cycle.sh
│   ├── doctor.sh
│   ├── heartbeat.sh
│   ├── install-cron.sh
│   ├── lib.sh
│   ├── linear-sync.py
│   ├── linear-sync.sh
│   ├── memory-sync.sh
│   ├── memory-health.sh
│   ├── memory-backend-index.py
│   ├── memory-backend-retrieve.py
│   ├── remediator.sh
│   ├── skill-memory-sync.py
│   ├── status.sh
│   ├── stats.sh
│   ├── steering-sync.sh
│   ├── uninstall-cron.sh
│   ├── verify.sh
│   └── adapters/
├── memory/
│   ├── curated/
│   ├── semantic/
│   ├── episodic/
│   ├── active/
│   └── daily/
├── skills/
│   ├── autodev-instance-ops/
│   └── learned/
├── prompts/
├── queue/
├── state/
├── steering/
└── security/
```

## What Runs

- `automation/doctor.sh`
  - Checks scheduler freshness, adapter availability, and the latest cycle outcome.
- `automation/remediator.sh`
  - Applies safe deterministic repairs for automation failures, such as clearing stale locks, rewriting GitHub HTTPS remotes to SSH when unattended SSH auth is available, and pushing safe pending autodev commits.
  - If repair is still needed, it can ask a supervision adapter for diagnosis only. Default supervision adapter is `claude`.
- `automation/verify.sh`
  - Runs the configured automated test and visual-test hooks on demand and records the latest results in package state files.
- `automation/memory-sync.sh`
  - Writes a cheap repository snapshot into the daily note, refreshes local steering state from the optional Linear mirror directory, refreshes learned skill memory, refreshes deterministic semantic/active memory surfaces, and rebuilds the hybrid memory backend.
- `automation/memory-health.sh`
  - Verifies the standardized memory contract: Hindsight API reachability, latest bank sync, OpenClaw memory plugin load state, and optional Swarm health.
- `automation/skill-memory-sync.py`
  - Promotes successful episodic sessions into reusable procedural skill docs under `skills/learned/` and refreshes the prompt-ready summary at `state/learned-skills.md`.
- `automation/memory-backend-index.py`
  - Builds the installed hybrid backend in `.agent/` with a local SQLite index, entity graph, run summaries, learned-skill indexing, and backend status metadata.
- `automation/memory-backend-retrieve.py`
  - Produces a query-scoped retrieval brief for the current focus and adds it to the cycle prompt bundle.
- `automation/steering-sync.sh`
  - Pulls from optional Linear mirror state first, imports optional task mirrors into local steering, preserves local-first task ownership, rewrites `map.json`, `outbox.jsonl`, and `last-sync.json`, then pushes queued outbound updates back to Linear.
- `automation/linear-sync.sh`
  - Runs the packaged zero-token Linear adapter against the local `steering/providers/linear/` state.
  - Supports `pull`, `push`, and `sync`, and skips cleanly when Linear credentials are not configured.
- `automation/heartbeat.sh`
  - Writes a local health summary for the repository and adapter state.
- `automation/stats.sh`
  - Renders a simple stats summary from the recorded delivery history and writes both markdown and HTML outputs into the package state directory.
- `automation/cycle.sh`
  - Builds a prompt bundle from project memory and runs one autonomous development cycle through the selected CLI adapter.
  - Reads `steering/active/` first, then `steering/inbox/`, and falls back to `queue/TODO.md` only when no steering task exists.
  - Records a last-cycle summary, writes episodic session memory, runs configured automated test and visual-test hooks before auto-commit or push, tracks whether the run produced a real repo diff, and can optionally auto-commit plus guarded auto-push.

## Memory Model

This package uses a layered memory system for coding agents:

- `memory/curated/`
  - stable objective, project framing, and compact operator memory
- `memory/semantic/`
  - durable truths like project map, invariants, commands, architecture, ownership
- `memory/episodic/`
  - decisions, failures, changelog, and compact session summaries
- `memory/active/`
  - current-task scratchpad, open questions, and next actions

Procedural memory lives alongside those files:

- `skills/learned/*/SKILL.md`
  - reusable procedures learned from successful sessions
- `state/learned-skills.md`
  - compact summary injected into unattended cycle prompts

It also installs a hybrid local memory backend under `.agent/`:

- `index.sqlite3`
  - searchable local retrieval index
- `entity_graph.json`
  - co-occurrence graph of memory entities
- `run_summaries.jsonl`
  - compact session summary stream

## Kraliki Memory Standard v1

This package now follows one shared contract:

- Markdown files under `memory/` remain the pinned, human-editable source of truth for objective, semantic, episodic, and active memory.
- `Hindsight` is the only durable learned memory layer. Autodev sync retains high-signal memory surfaces there and recalls from it first.
- Learned skill docs under `skills/learned/` are the procedural memory layer. They stay local-first, human-editable, and can also be retained into Hindsight as `learned_skill` items.
- The local SQLite backend, `rg`, and optional `mgrep` are retrieval tools, not competing long-term memory systems.
- Steering backlog and tracker mirrors are not durable memory by default. Active tasks can influence memory; inactive queues and mirrors stay local unless promoted into curated or episodic surfaces.
- Swarm capsules and blackboards are runtime coordination surfaces. They may mirror durable facts into Hindsight, but they are not the canonical long-term store.

This stays local-first and file-native. Hindsight adds the learned long-term layer; local retrieval still works from the repo package and codebase.

Default retrieval shape:

- Hindsight recall for durable learned memory
- local SQLite + symbolic memory scoring
- local `rg` code hints over the repository
- optional `mgrep` code retrieval when explicitly enabled

Standard write path:

- write or refresh pinned memory files under `memory/`
- refresh procedural skill memory under `skills/learned/`
- run `automation/memory-sync.sh`
- let `automation/memory-backend-index.py` retain the durable subset into Hindsight
- run `automation/memory-health.sh` when you want to confirm the contract has not drifted

## Verification Hooks

The package supports two optional verification hooks:

- `AUTODEV_TEST_COMMAND`
  - main automated verification, such as typecheck, unit tests, smoke tests, or a repo-specific gate
- `AUTODEV_VISUAL_TEST_COMMAND`
  - a second hook intended for visual or browser-level verification, such as a Playwright screenshot run or UI health gate

Supporting switches:

- `AUTODEV_TEST_REQUIRED`
- `AUTODEV_VISUAL_TEST_REQUIRED`
- `AUTODEV_TEST_TIMEOUT_SECONDS`
- `AUTODEV_VISUAL_TEST_TIMEOUT_SECONDS`

When configured, these hooks run automatically after a successful code-producing cycle and before any auto-commit or auto-push. They can also be run manually with:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/verify.sh
```

For reliability, prefer one of these patterns when you set the command in `.env`:

- simple command:
  - `AUTODEV_TEST_COMMAND='pnpm --dir frontend check'`
- complex shell or browser flow:
  - put it in a wrapper script under `automation/` and point the env var at that script

For `mgrep`, the intended production shape is:

- repo-local backend remains the canonical memory substrate
- `mgrep` is an optional code-retrieval accelerator
- keep it disabled by default unless you explicitly want the paid cloud-backed layer
- use one store per package via `AUTODEV_MEMORY_MGREP_STORE`
- authenticate once with `mgrep login` or set `MXBAI_API_KEY` for unattended/headless use
- use `.mgrepignore` in the target repo root to exclude noisy tracked paths or large historical folders

The package also ships a local skill at `skills/autodev-instance-ops/SKILL.md` so unattended and manually started CLI agents can use the same read/write memory contract.

## Steering Model

This package uses a local-first steering filesystem:

- `steering/active/`
  - task files that should drive the next unattended cycles
- `steering/inbox/`
  - ready task files waiting to be promoted
- `steering/done/`
  - completed task files
- `steering/archive/`
  - stale or retired task files
- `steering/providers/linear/`
  - optional Linear adapter state for local mirror, mapping, and queued outbound sync

Local steering is canonical. Linear is optional and should be treated as an adapter, not the source of truth.

## Supported Adapters

- `auto`
- `codex`
- `claude`
- `opencode`
- `kimi`
- `custom`

`auto` picks the first installed adapter in this order: `codex`, `claude`, `opencode`, `kimi`.

## Setup

1. Review `.env`.
2. Review the packaged skill and memory files.
3. Update the objective, steering, and queue files.
4. Install cron:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/install-cron.sh
```

5. Check status:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/status.sh
```

6. Run an initial memory sync:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/memory-sync.sh
```

7. Check memory health:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/memory-health.sh
```

8. View stats:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/stats.sh
open /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/state/stats.html
```

9. Optional: run the configured test hooks manually:

```bash
/bin/bash /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment/automation/verify.sh
```

10. Optional: from your `open-kraliki` checkout, serve a combined live control dashboard if you run one or more repo-local packages:

```bash
python3 automation/repo-local/dashboard-server.py \
  --autodev-root /Users/matejhavlin/github/websites/perfectmission.co.uk/perfectmission-website-autodevelopment \
  --port 18880

open "http://127.0.0.1:18880"
```

The live dashboard can pause or resume a package by toggling `AUTODEV_ENABLED`, run `verify.sh` on demand, and reinstall that package's cron block. Use this when you want to work manually in the target repository without colliding with unattended cycles or remediator actions.
It can also run `automation/linear-sync.sh` directly when you want to force a Linear import/export cycle without waiting for the next steering sync.

## Safety Defaults

- `AUTODEV_REQUIRE_CLEAN_TREE=true`
- `AUTODEV_ENABLED=true`
- `AUTODEV_AUTO_COMMIT=false`
- `AUTODEV_AUTO_PUSH=false`
- cycle active hours default to `8-20`
- heartbeat active hours default to `8-24`
- `AUTODEV_CLEAN_TREE_EXCLUDES` can ignore known noisy tracked paths when needed
- doctor runs hourly by default at minute `7`
- remediator runs hourly by default at minute `37`
- runtime governance is enabled for autonomous cycles

This means the package will not start a coding cycle when tracked project-scope changes already exist, and it will stop repeated or excessive LLM cycles.

If you want unattended progress across repeated cycles in a tracked repository, set `AUTODEV_AUTO_COMMIT=true`. Otherwise the first successful tracked edit will pause later cycles until you commit or clean the worktree yourself.

If you want unattended remote propagation too, set `AUTODEV_AUTO_PUSH=true` and keep `AUTODEV_PUSH_ALLOWED_PREFIXES` narrow. The package will only push when all pending commit subjects match the allowed prefixes, which prevents it from blindly shipping unrelated local backlog.

For unattended push on macOS cron, prefer an SSH git remote such as `git@github.com:owner/repo.git`. HTTPS remotes may depend on interactive credential helpers that are unavailable to background cron jobs.

The remediator is meant for safe automation repair, not arbitrary repo mutation. Deterministic fixes run first. The supervision adapter is only used to produce diagnosis when the package still needs operator attention.
