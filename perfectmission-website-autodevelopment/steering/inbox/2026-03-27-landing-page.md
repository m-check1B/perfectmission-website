---
id: pm-2026-03-27-002
title: Build landing page hero and homepage structure for Perfect Mission website
status: inbox
priority: high
source: local
linear_id:
area: website pages, layout, design-language
labels: [website, landing-page, design-language, first-content]
updated_at: 2026-03-27T21:10:00Z
---

# Task

## Goal

Build the homepage structure for Perfect Mission Ltd using the design-language spec at `steering/design-language.md`. Start with the hero section and core homepage layout — the site has only the autodev scaffold and design spec, no pages yet.

## Context

Perfect Mission is an AI-driven real estate consultancy. The design language (written by Advisory Council sprint) specifies:
- Dark-dominant hybrid: Deep Navy `#0A1628` + Gold `#C9A84C` + Off-White `#F8F6F1`
- Typography: Playfair Display (headings) + Inter (body) + JetBrains Mono (data)
- Authoritative, precise, forward-looking mood

From the roadmap Phase 1:
- Hero: "Great decisions are built on thousands of questions getting answered" (or PM-specific copy)
- How it Works section (3-round visual flow)
- Services overview cards
- Light theme for data sections, dark for authority sections

The project has 2 commits (initial + autodev scaffold). No pages, no components, no routing yet.

## Acceptance

- Homepage HTML/component exists with hero section, intro, and services overview
- Uses the design-language CSS variables and tokens (colors, typography, spacing from spec)
- Responsive (mobile-first, containers 640–1400px as spec defines)
- Follows the 70% dark / 30% light page pattern from design spec
- Navigation header with company name
- CTA button styled with Gold accent
- At least 2 sections beyond hero (e.g. "How It Works", "Services")
- Git commit with the changes

## Next

- Read `steering/design-language.md` for exact colors, typography, spacing values
- Determine project structure (static HTML? SvelteKit? Next.js?) — check if there's a package.json or framework setup
- Build the first page following the spec
- Keep it simple — content structure first, polish later

## Notes

- This is a website project, not a SvelteKit app — check what framework is configured
- The design spec has exact hex values, font imports, spacing grid
- Prefers quality over speed — one polished page beats three rough ones
- Reference: `steering/design-language.md` has 590-line spec with all tokens
