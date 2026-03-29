---
id: pm-2026-03-29-001
title: Resolve Chromium sandbox blocking for visual verification
status: inbox
priority: high
source: axis-ops
linear_id:
area: automation verification
labels: [verification, browser, lighthouse, blocking]
updated_at: 2026-03-29T16:36:00Z
---

# Task

## Goal

Find a way to run browser-based verification (Lighthouse, rendered mobile check, accessibility audit) for the Perfect Mission website despite the macOS Mach-port sandbox blocking Chromium in autodev cycles.

## Context

Every successful cycle since 2026-03-28 has identified "run a real browser/Lighthouse pass" as the next step, but it never completes because Chromium is blocked by macOS Mach-port sandbox restrictions inside the autodev sandbox. This means:

- No rendered mobile viewport verification
- No Lighthouse performance/accessibility/SEO scores
- No real accessibility audit (only source-level `html-validate` and `npm run check`)
- The website may have runtime issues invisible to source-only checks

This is the highest-value unresolved gate for the project.

## Possible Approaches

1. **External verification script:** Create a script that runs outside the sandbox (e.g., via `exec` on the host) to run Lighthouse against the local preview
2. **Headless Chrome with --no-sandbox:** Configure Playwright or Puppeteer to run with `--no-sandbox` flag
3. **Deploy and test remotely:** Push to a staging URL and run Lighthouse against the deployed site
4. **Use Playwright MCP:** Configure Playwright as an MCP server with proper sandbox bypass for headless verification

## Acceptance

- Lighthouse audit runs successfully against the built or previewed site
- Results include performance, accessibility, and SEO scores
- Any score below 95 triggers a fix cycle
- The verification method is reusable for future cycles

## Notes

- Site is SvelteKit with static adapter, builds to `build/`
- Preview runs at `http://127.0.0.1:4179` via `npm run preview`
- `npm run check` and `npm run build` already pass
- `html-validate` passes on built output
- The gap is rendered behavior under real browser conditions
