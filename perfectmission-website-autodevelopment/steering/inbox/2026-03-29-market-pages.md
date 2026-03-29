---
id: pm-2026-03-29-002
title: Build market detail pages for top 3 CEE markets
status: inbox
priority: high
source: ops-review
area: src/routes/
labels: [revenue, content, markets, sveltekit]
updated_at: 2026-03-29T18:36:00Z
---

# Task

## Goal

Create market detail pages for the top 3 CEE markets (Czech Republic, Poland, Romania) so Perfect Mission has real content beyond the homepage hero. Each page should explain the AI-driven approach for that specific market.

## Context

The hero is finalized and the site builds cleanly. But there's no depth yet — a visitor who clicks through from the hero has nowhere to go. The `/markets` route exists but needs substantive pages for the highest-value markets.

## Acceptance

- [ ] `/markets/czech-republic` page with market-specific value prop, data points, and CTA
- [ ] `/markets/poland` page (same structure)
- [ ] `/markets/romania` page (same structure)
- [ ] Each page follows design-language.md spec
- [ ] `npm run build` passes
- [ ] `npm run check` passes
- [ ] Committed and pushed to `origin/main`
