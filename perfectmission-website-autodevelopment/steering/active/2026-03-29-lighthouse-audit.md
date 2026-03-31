---
id: pm-2026-03-29-002
title: Run Lighthouse audit and fix top accessibility/performance issues
status: inbox
priority: high
source: ops-review
area: src/ 
labels: [quality, accessibility, performance, lighthouse, seo]
updated_at: 2026-03-29T18:36:00Z
---

# Task

## Goal
Run a Lighthouse audit against the deployed or preview site and fix the top 3 accessibility and performance issues found. The last two cycles flagged "real browser/Lighthouse gate" as the next best step but couldn't execute it in-sandbox.

## Context
- SvelteKit site builds clean (`npm run check` + `npm run build` pass)
- Cookie banner accessibility improved (commit 34fe9e4)
- Mobile menu keyboard flow improved (commit 0973f9b)
- But no Lighthouse score baseline exists yet
- The autodev environment can't run Chromium reliably (Mach-port sandbox failure on macOS)
- This task should use the CLI Lighthouse path: `npx lighthouse http://127.0.0.1:4179 --output=json --chrome-flags="--headless --no-sandbox"`

## Acceptance
- [ ] Lighthouse JSON report generated and saved to `logs/lighthouse-*.json`
- [ ] Top 3 issues identified with specific file/line references
- [ ] Fixes applied for at least the top 2 issues
- [ ] `npm run check` and `npm run build` still pass after fixes
- [ ] Second Lighthouse run shows improvement on fixed categories
- [ ] Committed and pushed

## Notes
- Preview server: `npm run preview -- --host 127.0.0.1 --port 4179`
- Focus areas: accessibility (WCAG AA target), performance (mobile), SEO (meta tags)
- The design-language.md specifies Playfair Display + Inter fonts — check font loading impact
