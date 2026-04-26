---
name: learned-perfectmission-website-sveltekit-website
description: Learned Kraliki procedure for perfectmission-website: sveltekit website. Use when the current task matches this previously successful pattern.
---

# Learned Skill: sveltekit website

## When To Use

- Project: `perfectmission-website`
- Trigger: task focus matches `Build SvelteKit website for Perfect Mission — AI-driven real estate consultancy (steering/active/2026-03-27-sveltekit-website.md)`
- Evidence: `124` successful session(s); latest `2026-04-04T06:49:52Z`
- Steering source: `steering/active/2026-03-27-sveltekit-website.md`

## Proven Procedure

1. Re-read the current focus and the matching steering task before editing.
2. Inspect the same file areas that changed in prior successful runs.
3. Reuse the representative command pattern below when it fits the task.
4. Run the same verification shape before claiming success.
5. Update session memory and refine this skill if a better pattern emerges.

## Files Usually Touched

- `scripts/verify-market-source-hashes.mjs`
- `package.json`

## Representative Commands

- `git status --short`
- `./perfectmission-website-autodevelopment/automation/status.sh`
- `npm run preview -- --host 127.0.0.1 --port 4175`
- `temp-cache Playwright probes for Chromium, WebKit, and Firefox`
- `npm run verify:market-source-hashes -- --help`
- `node --experimental-strip-types --test src/lib/cookie-consent-state.test.ts src/lib/market-source-anchors.test.ts`
- `npm run check`
- `attempted `git add -- package.json scripts/verify-market-source-hashes.mjs && git commit -m "chore: add market source hash verifier"`

## Verification Pattern

- npm run verify:market-source-hashes -- --help` passed and now documents the stored-consent coverage. The product diff is isolated to the verifier script in website scope. A real browser pass did not complete here because the MCP browser navigation was cancelled, and commit is still blocked in this sandbox with `.git/index.lock: Operation not permitted`.
- automated-test: not-configured
- visual-test: not-configured
- npm run verify:market-source-hashes -- --help` passed.
- Targeted tests passed: `8/8`.
- npm run check` passed with `0 errors` and `0 warnings`.

## Evidence

- Latest commit: `9cd7e2b9542d6607e1aba0858af1cd78a34887e7`
- Latest session: `20260404T080002.md`
- Next-step heuristic: on a host shell outside this sandbox, run `npm run dev -- --host 127.0.0.1 --port 4175` and then `npm run verify:market-source-hashes -- http://127.0.0.1:4175/` to exercise fresh-consent, malformed-hash, and stored-consent stable/legacy flows in a real browser.

## Recent Successful Summary

1. Chosen task: extend the host-side Czech market hash verifier so it also proves the post-consent re-entry case, not just first-load banner deferral. scripts/verify-market-source-hashes.mjs now seeds stored consent into a fresh Playwright context, and scripts/verify-market-source-hashes.mjs and scripts/verify-market-source-hashes.mjs verify that stable and legacy deep links open immediately without showing the cookie banner when consent is already stored. 2. Files changed: scripts/verify-market-source-hashes.mjs. The pre-existing learned-skill diff in `perfectmission-website-autodevelopment/.../SKILL.md` was left untouched.
