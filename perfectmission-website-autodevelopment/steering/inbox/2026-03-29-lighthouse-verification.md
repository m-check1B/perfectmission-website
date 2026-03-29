---
id: pm-2026-03-29-001
title: Run Lighthouse and real-browser verification on Perfect Mission hero
status: inbox
priority: high
source: axis-ops
linear_id:
area: src/routes/+page.svelte src/app.css
labels: [website, performance, accessibility, verification]
updated_at: 2026-03-29T17:06:00Z
---

# Task

## Goal
Run real browser and Lighthouse verification on the finalized Perfect Mission homepage hero. Last cycle (`20260329T160001`) passed all build checks but flagged rendered mobile/accessibility proof as the highest-value missing gate.

## Context
The hero was just finalized with sharper positioning copy, revised CTA labels, and improved mobile CSS. All build-time checks pass (npm check, npm build, html-validate). Now we need runtime verification to catch visual/accessibility issues that static analysis misses.

## Acceptance
- [ ] Build the site (`npm run build`) and serve locally
- [ ] Run Lighthouse audit — target 90+ performance, accessibility, SEO
- [ ] Check hero rendering at 320px, 375px, 768px, and 1024px breakpoints
- [ ] Verify CTA buttons are keyboard-accessible and have proper focus states
- [ ] Document any issues found and fix P0/P1 items
- [ ] Commit and push fixes to main
