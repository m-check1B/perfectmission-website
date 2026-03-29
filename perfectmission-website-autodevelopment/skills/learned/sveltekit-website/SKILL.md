---
name: learned-perfectmission-website-sveltekit-website
description: Learned Kraliki procedure for perfectmission-website: sveltekit website. Use when the current task matches this previously successful pattern.
---

# Learned Skill: sveltekit website

## When To Use

- Project: `perfectmission-website`
- Trigger: task focus matches `Build SvelteKit website for Perfect Mission — AI-driven real estate consultancy (steering/active/2026-03-27-sveltekit-website.md)`
- Evidence: `9` successful session(s); latest `2026-03-29T14:02:45Z`
- Steering source: `steering/active/2026-03-27-sveltekit-website.md`

## Proven Procedure

1. Re-read the current focus and the matching steering task before editing.
2. Inspect the same file areas that changed in prior successful runs.
3. Reuse the representative command pattern below when it fits the task.
4. Run the same verification shape before claiming success.
5. Update session memory and refine this skill if a better pattern emerges.

## Files Usually Touched

- `src/app.css`
- `src/routes/+page.svelte`
- `src/lib/site.ts`
- `src/routes/markets/[slug]/+page.svelte`

## Representative Commands

- `./perfectmission-website-autodevelopment/automation/status.sh`
- `git status --short`
- `sed -n '1,240p' 'src/routes/markets/[slug]/+page.svelte'`
- `sed -n '1,220p' src/lib/components/Header.svelte`
- `sed -n '560,690p' src/app.css`
- `sed -n '1,260p' src/routes/markets/+page.svelte`
- `sed -n '1,220p' src/lib/market-intelligence.ts`
- `sed -n '1,220p' src/lib/components/Seo.svelte`

## Verification Pattern

- automated-test: not-configured
- visual-test: not-configured
- npm run check`: passed
- npm run build`: passed
- html-validate build/index.html build/markets.html build/markets/poland.html`: passed
- Built output now shows correct asset metadata URLs such as `https://perfectmission.co.uk/social/perfect-mission-og.png` and `https://perfectmission.co.uk/favicon.svg` with no trailing slash

## Evidence

- Latest commit: `00e757196f63fe3686ba4872284cfd4f2b0e207b`
- Latest session: `20260329T160001.md`
- Next-step heuristic: run a real browser/Lighthouse pass against the built or deployed site and fix the next measured runtime issue, since rendered mobile/accessibility proof is still the highest-value missing gate.

## Recent Successful Summary

Chosen task: finalize the homepage hero so the first screen clearly sells Perfect Mission as an AI-driven real estate consultancy, with stronger CTAs and better mobile behavior. I changed `src/routes/+page.svelte` and `src/app.css`. The hero now uses sharper positioning copy, revised CTA labels, a compact signal list, and a clearer right-hand proof panel with a priority-review link. The CSS update tightens the hero grid, switches buttons to a spec-aligned rectangular radius, and improves small-screen hero spacing and signal stacking at `src/app.css`.
