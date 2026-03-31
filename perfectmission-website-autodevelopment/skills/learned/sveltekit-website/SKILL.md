---
name: learned-perfectmission-website-sveltekit-website
description: Learned Kraliki procedure for perfectmission-website: sveltekit website. Use when the current task matches this previously successful pattern.
---

# Learned Skill: sveltekit website

## When To Use

- Project: `perfectmission-website`
- Trigger: task focus matches `Build SvelteKit website for Perfect Mission — AI-driven real estate consultancy (steering/active/2026-03-27-sveltekit-website.md)`
- Evidence: `52` successful session(s); latest `2026-03-31T16:32:37Z`
- Steering source: `steering/active/2026-03-27-sveltekit-website.md`

## Proven Procedure

1. Re-read the current focus and the matching steering task before editing.
2. Inspect the same file areas that changed in prior successful runs.
3. Reuse the representative command pattern below when it fits the task.
4. Run the same verification shape before claiming success.
5. Update session memory and refine this skill if a better pattern emerges.

## Files Usually Touched

- `src/lib/components/Header.svelte`
- `src/lib/components/MarketCard.svelte`
- `src/routes/+page.svelte`

## Representative Commands

- `./perfectmission-website-autodevelopment/automation/status.sh`
- `git status --short`
- `sed -n '1,220p' perfectmission-website-autodevelopment/skills/learned/sveltekit-website/SKILL.md`
- `sed -n '1,260p' src/lib/components/Header.svelte`
- `sed -n '1,260p' src/lib/components/MarketCard.svelte`
- `sed -n '1,360p' src/routes/+page.svelte`
- `sed -n '260,560p' src/lib/components/Header.svelte`
- `sed -n '360,470p' src/routes/+page.svelte`

## Verification Pattern

- npm run check` passed with 0 errors and 0 warnings.
- npm run build` passed and `@sveltejs/adapter-static` wrote the site to `build/`.
- Commit created: `9bad035` (`fix: expose mobile menu backdrop control`).
- automated-test: not-configured
- visual-test: not-configured
- npm run check` passed with 0 errors and 0 warnings. `npm run build` passed and `@sveltejs/adapter-static` wrote the site to `build/`. Commit created: `1765227` (`fix: hide decorative icons from screen readers`).

## Evidence

- Latest commit: `9bad035901691d028f9cade3d3d48df2e5ee5720`
- Latest session: `20260331T183001.md`
- Next-step heuristic: run a real browser/Lighthouse pass against the local preview or deployed site outside this sandbox, then fix the next measured rendered/runtime issue. The highest-value unresolved gate is still true browser proof rather than another source-only accessibility guess.

## Recent Successful Summary

Chosen task: fix the mobile navigation backdrop so it is not an interactive control hidden from assistive technology. Files changed: src/lib/components/Header.svelte
