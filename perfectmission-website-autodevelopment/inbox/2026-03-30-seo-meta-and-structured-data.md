---
id: pm-2026-03-30-001
title: Add SEO meta tags, Open Graph, and JSON-LD structured data to perfectmission.co.uk
status: inbox
priority: high
source: axis-ops
linear_id:
area: src/routes/+layout.svelte src/routes/+page.svelte
labels: [seo, meta, structured-data, visibility, opengraph]
updated_at: 2026-03-30T19:06:00Z
---

# Task

## Goal
Add complete SEO metadata, Open Graph tags, and JSON-LD structured data to the SvelteKit site so the site is discoverable by search engines and shares cleanly on social platforms.

## Context
- SvelteKit site is building and pushing cleanly (commits 7529c09, recent mobile nav fix)
- Active task `2026-03-27-sveltekit-website.md` lists Lighthouse 95+ and SEO meta tags as acceptance criteria
- Lighthouse audit task (`2026-03-29-lighthouse-audit.md`) flagged SEO as a focus area
- No audit has been run yet — first thing to fix is ensuring meta coverage is complete

## Acceptance
- [ ] `<svelte:head>` in +layout.svelte includes: `<title>`, `<meta name="description">`, `<link rel="canonical">`
- [ ] Open Graph tags: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`
- [ ] Twitter Card tags: `twitter:card`, `twitter:title`, `twitter:description`
- [ ] JSON-LD structured data block on homepage: `Organization` schema with name, url, address (20 Wenlock Road, London N1 7GU), founder details
- [ ] All meta content reflects Perfect Mission Ltd positioning (AI-driven real estate consultancy)
- [ ] `npm run check` and `npm run build` pass
- [ ] Committed and pushed to origin

## Notes
- Company: Perfect Mission Ltd, Company No. 08651715
- Address: 20 Wenlock Road, London N1 7GU
- Email: info@perfectmission.co.uk
- Keep image references relative to the deployed domain (perfectmission.co.uk)
- Don't add a hero image yet if none exists — use a placeholder og:image path that can be swapped
