---
id: pm-2026-03-29-001
title: Run Lighthouse + browser audit on Perfect Mission site
status: pending
priority: high
source: local
linear_id:
area: src/
labels: [performance, accessibility, quality]
created_at: 2026-03-29T01:04:00Z
---

# Task

## Goal

Run a real Lighthouse audit and browser verification against the built Perfect Mission site. Recent cycles fixed tablet grids, market grids, and contact links — but all without browser verification due to runtime issues.

## Context

Multiple CSS fixes landed (tablet grids, market overview, contact links) but browser MCP calls were cancelled each time. The site needs a comprehensive audit to catch any remaining issues in mobile navigation, keyboard flow, accessibility, or performance.

## Requirements

1. Build the site (`npm run build`)
2. Serve the built site locally
3. Run Lighthouse audit (performance, accessibility, best practices, SEO)
4. Check mobile navigation and keyboard flow manually or via automation
5. Fix any critical or high-severity issues found

## Acceptance Criteria

- [ ] Lighthouse scores captured (all 4 categories)
- [ ] No critical accessibility issues
- [ ] Mobile navigation works correctly
- [ ] Keyboard focus flow is logical
- [ ] Any fixes committed and pushed

## Priority

High — site quality directly impacts conversion. Multiple unverified CSS changes need validation.

## Note

Auto-push has been failing on this project. Verify push works after committing fixes.
