---
name: learned-perfectmission-website-sveltekit-website
description: Learned Kraliki procedure for perfectmission-website: sveltekit website. Use when the current task matches this previously successful pattern.
---

# Learned Skill: sveltekit website

## When To Use

- Project: `perfectmission-website`
- Trigger: task focus matches `Build SvelteKit website for Perfect Mission — AI-driven real estate consultancy (steering/active/2026-03-27-sveltekit-website.md)`
- Evidence: `2` successful session(s); latest `2026-03-28T13:36:36Z`
- Steering source: `steering/active/2026-03-27-sveltekit-website.md`

## Proven Procedure

1. Re-read the current focus and the matching steering task before editing.
2. Inspect the same file areas that changed in prior successful runs.
3. Make one narrow change aligned to the proven focus instead of broad refactors.
4. Run the same verification shape before claiming success.
5. Update session memory and refine this skill if a better pattern emerges.

## Files Usually Touched

- `src/app.css`
- `src/app.html`
- `src/routes/+page.svelte`
- `src/lib/actions/reveal.ts`
- `index.html`
- `.gitignore`
- `package-lock.json`
- `package.json`

## Verification Pattern

- automated-test: not-configured
- visual-test: not-configured

## Evidence

- Latest commit: `91f6afdf12c5b0804639d44aa228bd6f8c11cdda`
- Latest session: `20260328T143001.md`
- Next-step heuristic: - **Next Best Step**

## Recent Successful Summary

**Chosen Task** Implemented spec-aligned scroll reveal motion for the homepage and confirmed the deployment surface already points at `build/` in docker-compose.yml. The motion system is progressive-enhancement based: a reusable action in src/lib/actions/reveal.ts, early JS detection in src/app.html, reveal hooks across the homepage in src/routes/+page.svelte, and matching CSS plus reduced-motion handling in src/app.css. **Files Changed** - src/lib/actions/reveal.ts - src/routes/+page.svelte - src/app.css - src/app.html **Commands Run** - `rg -n --smart-case "perfectmission|build/|docker-compose|httpd" -g '!perfectmission-website-autodevelopment/**' ..` - `sed -n '720,780p' ../docker-compose.yml` - `git diff --stat -- src/app.html src/app.css src/routes/+page.svelte src/lib/actions/reveal.ts` - `NPM_CONFIG_CACHE=/tmp/perfectmission-npm-cache npm run check` - `NPM_CONFIG_CACHE=/tmp/perfec
