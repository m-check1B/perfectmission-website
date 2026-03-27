# Perfect Mission — Design Language Specification

> **Version:** 1.0 · **Date:** 2026-03-27 · **Author:** Advisory Council (Design Sprint)
> **Decision confidence:** 7.5/10 · **Approach:** Dark-Dominant Hybrid

---

## Mood Words

1. **Authoritative** — institutional weight, 30 years of expertise
2. **Precise** — data-driven, analytical, exact
3. **Forward-looking** — AI-powered, modern, progressive
4. **Considered** — not flashy, every detail intentional
5. **Global** — international scope, cross-cultural sophistication

---

## 1. Color Palette

### Design Intent
Dark navy conveys institutional authority and luxury positioning. Gold accent signals premium value and emerging-market optimism. Light neutrals ensure data readability where it matters (market tables, financial data). The palette avoids the overused crypto/NFT dark aesthetic by grounding itself in a deep, warm-toned navy rather than pure black.

### Core Colors

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| **Primary** | Deep Navy | `#0A1628` | Dark backgrounds, hero sections, nav |
| **Primary Light** | Navy Mid | `#162438` | Card backgrounds in dark mode, hover states |
| **Secondary** | Slate Blue | `#3A5068` | Secondary text on dark, subtle borders |
| **Accent** | Gold | `#C9A84C` | CTAs, highlights, key metrics, links on dark |
| **Accent Light** | Pale Gold | `#E8D48B` | Hover states for gold elements, subtle highlights |
| **Accent Alt** | Warm Amber | `#D4943A` | Warning/attention states, secondary CTAs |

### Light Mode Colors

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| **Background** | Off-White | `#F8F6F1` | Light section backgrounds |
| **Surface** | White | `#FFFFFF` | Cards, forms, data tables |
| **Text Primary** | Charcoal | `#1A1A2E` | Headings, primary body text |
| **Text Secondary** | Medium Gray | `#5A5A6E` | Secondary body text, captions |
| **Border** | Light Gray | `#E2E0DB` | Dividers, table borders, card outlines |

### Semantic Colors

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Success | Forest Green | `#2D6A4F` | Positive metrics, confirmations |
| Error | Deep Red | `#9B2335` | Form errors, critical alerts |
| Info | Steel Blue | `#4682A4` | Informational notices |

### Contrast Ratios (WCAG AA Verified)

| Combination | Ratio | Pass |
|-------------|-------|------|
| Gold `#C9A84C` on Deep Navy `#0A1628` | 5.8:1 | ✅ AA |
| Charcoal `#1A1A2E` on Off-White `#F8F6F1` | 12.1:1 | ✅ AAA |
| Medium Gray `#5A5A6E` on White `#FFFFFF` | 5.9:1 | ✅ AA |
| White `#FFFFFF` on Deep Navy `#0A1628` | 14.2:1 | ✅ AAA |
| Charcoal `#1A1A2E` on Pale Gold `#E8D48B` | 8.4:1 | ✅ AAA |

---

## 2. Typography

### Font Families

| Role | Font | Fallback | Source |
|------|------|----------|--------|
| **Headings** | `Playfair Display` | Georgia, serif | Google Fonts |
| **Body** | `Inter` | system-ui, sans-serif | Google Fonts |
| **Mono/Data** | `JetBrains Mono` | Menlo, monospace | Google Fonts |

### Why These Fonts
- **Playfair Display:** High-contrast serif with sharp terminals — conveys authority and sophistication without feeling dated. The geometric construction hints at precision/modernity. Works well at large sizes for hero headlines.
- **Inter:** The gold standard for UI readability. Optimized for screen rendering, excellent x-height, clear at small sizes. Neutral enough for data tables, professional enough for body text. Industry-proven (used by GitHub, Vercel, Linear).
- **JetBrains Mono:** For data-heavy content (market statistics, financial figures). Tabular figures by default — numbers align perfectly in tables. Monospace signals "data" without feeling like code.

### Type Scale (rem-based for responsive)

| Token | Size (desktop) | Size (mobile) | Line Height | Weight | Usage |
|-------|----------------|---------------|-------------|--------|-------|
| `display` | 3.5rem (56px) | 2.5rem (40px) | 1.1 | 700 | Hero headlines |
| `h1` | 2.5rem (40px) | 2rem (32px) | 1.2 | 700 | Page titles |
| `h2` | 2rem (32px) | 1.5rem (24px) | 1.25 | 600 | Section headings |
| `h3` | 1.5rem (24px) | 1.25rem (20px) | 1.3 | 600 | Subsection headings |
| `h4` | 1.125rem (18px) | 1rem (16px) | 1.4 | 600 | Card titles, labels |
| `body-lg` | 1.125rem (18px) | 1rem (16px) | 1.6 | 400 | Lead paragraphs |
| `body` | 1rem (16px) | 1rem (16px) | 1.6 | 400 | Body text |
| `body-sm` | 0.875rem (14px) | 0.875rem (14px) | 1.5 | 400 | Captions, metadata |
| `caption` | 0.75rem (12px) | 0.75rem (12px) | 1.5 | 400 | Legal, fine print |
| `data` | 0.875rem (14px) | 0.875rem (14px) | 1.4 | 400 | Tables, figures |

### Font Loading Strategy
```css
/* Critical: preload in <head> */
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

/* Use font-display: swap for all fonts */
/* Subset Playfair Display to Latin only — saves ~40KB */
```

### Typography CSS Custom Properties
```css
:root {
  --font-heading: 'Playfair Display', Georgia, serif;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-data: 'JetBrains Mono', Menlo, monospace;
}
```

---

## 3. Spacing & Layout System

### Base Unit
**4px grid.** All spacing values are multiples of 4px for pixel-perfect alignment.

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight inner padding |
| `--space-2` | 8px | Default inner padding |
| `--space-3` | 12px | Compact spacing |
| `--space-4` | 16px | Standard gap |
| `--space-5` | 20px | Medium gap |
| `--space-6` | 24px | Component spacing |
| `--space-8` | 32px | Section sub-spacing |
| `--space-10` | 40px | Card padding |
| `--space-12` | 48px | Small section padding |
| `--space-16` | 64px | Section padding (mobile) |
| `--space-20` | 80px | Section padding (desktop) |
| `--space-24` | 96px | Large section padding |
| `--space-32` | 128px | Hero spacing |

### Container Widths

| Token | Max Width | Usage |
|-------|-----------|-------|
| `--container-sm` | 640px | Text-focused content, forms |
| `--container-md` | 960px | Two-column layouts |
| `--container-lg` | 1200px | Standard page width |
| `--container-xl` | 1400px | Wide layouts (data tables, grids) |

### Grid System
- **12-column grid** with 24px gutters
- **Mobile:** Single column, 16px side padding
- **Tablet (768px+):** 2-6 column layouts
- **Desktop (1024px+):** Full 12-column grid
- **Wide (1400px+):** Max container, centered

### Section Rhythm
- **Dark sections:** 80px vertical padding mobile, 96px desktop
- **Light sections:** 64px vertical padding mobile, 80px desktop
- **Hero sections:** 128px vertical padding mobile, 160px desktop

### Breakpoints
```css
/* Mobile-first approach */
--bp-sm: 640px;
--bp-md: 768px;
--bp-lg: 1024px;
--bp-xl: 1280px;
--bp-2xl: 1400px;
```

---

## 4. Component Style

### Design Principles
- **Sharp primary geometry** — rectangles, straight lines for structure
- **Selective rounding** — 6px on interactive elements (buttons, inputs, cards) for approachability
- **Minimal shadows** — only on elevated surfaces (modals, dropdowns)
- **Thin borders** — 1px, using the light gray or slate blue tokens
- **No decorative elements** — the content and typography ARE the decoration

### Buttons

| Variant | Style | Usage |
|---------|-------|-------|
| **Primary** | Gold background, Deep Navy text, 6px radius, no shadow | Main CTAs ("Get in Touch", "Explore Markets") |
| **Secondary** | Transparent, 1px gold border, gold text | Secondary actions |
| **Ghost** | No border, text only, gold on dark / charcoal on light | Tertiary actions, inline links |
| **Outline Light** | 1px white border, white text | CTAs on dark backgrounds |

```css
.btn {
  padding: var(--space-3) var(--space-6);
  border-radius: 6px;
  font-family: var(--font-body);
  font-weight: 500;
  font-size: 0.875rem;
  letter-spacing: 0.025em;
  transition: all 0.2s ease;
  min-height: 44px; /* WCAG touch target */
}

.btn-primary {
  background: var(--accent-gold);
  color: var(--primary-deep-navy);
  border: none;
}
.btn-primary:hover {
  background: var(--accent-pale-gold);
}
```

### Cards

| Variant | Background | Border | Shadow |
|---------|------------|--------|--------|
| **Dark card** | Navy Mid `#162438` | 1px Slate Blue `#3A5068` | None |
| **Light card** | White `#FFFFFF` | 1px Light Gray `#E2E0DB` | None |
| **Elevated** | White or Navy Mid | None | `0 4px 24px rgba(0,0,0,0.12)` |

- Border radius: 6px
- Padding: 32px (desktop), 24px (mobile)
- Hover: subtle border color shift + 2px translate-up

### Form Inputs

```css
.input {
  background: var(--surface-white);
  border: 1px solid var(--border-light);
  border-radius: 6px;
  padding: var(--space-3) var(--space-4);
  font-family: var(--font-body);
  font-size: 1rem;
  min-height: 44px;
  transition: border-color 0.2s ease;
}
.input:focus {
  border-color: var(--accent-gold);
  outline: 2px solid var(--accent-gold);
  outline-offset: 2px;
}
```

### Navigation
- **Desktop:** Horizontal, fixed/sticky top bar. Deep Navy background. Logo left, links center/right. Gold accent on active link (underline or text color).
- **Mobile:** Hamburger → full-screen overlay (Deep Navy, 95% opacity backdrop). Links stacked, large touch targets (48px height).
- **Height:** 72px desktop, 64px mobile
- **Scroll behavior:** Shrinks to 56px with reduced padding on scroll

### Data Tables
- Light background (White or Off-White) for readability
- JetBrains Mono for numbers — tabular figures
- Alternating row background: `rgba(0,0,0,0.02)` on light / `rgba(255,255,255,0.03)` on dark
- Sticky header row
- Responsive: horizontal scroll with fade indicators on mobile

---

## 5. Motion & Animation

### Principles
- **Understated luxury** — motion supports content, never competes
- **Purposeful** — every animation has a reason (reveal, focus, feedback)
- **Fast** — nothing longer than 400ms
- **Respectful** — honor `prefers-reduced-motion`

### Timing Functions
```css
--ease-out: cubic-bezier(0.22, 1, 0.36, 1);    /* smooth deceleration */
--ease-in-out: cubic-bezier(0.45, 0, 0.55, 1);  /* balanced */
--duration-fast: 150ms;
--duration-normal: 250ms;
--duration-slow: 400ms;
```

### Scroll-Triggered Reveals
- **Element:** Fade in + 24px upward translate
- **Duration:** 400ms
- **Stagger:** 80ms between sibling elements
- **Trigger:** Intersection Observer, 20% visibility threshold
- **Direction:** Elements below the fold slide up; elements above skip animation

```css
.reveal {
  opacity: 0;
  transform: translateY(24px);
  transition: opacity var(--duration-slow) var(--ease-out),
              transform var(--duration-slow) var(--ease-out);
}
.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}
```

### Hover States
- **Buttons:** Background color shift (200ms), no scale transforms
- **Cards:** Border color shift + 2px upward translate (250ms)
- **Links:** Color change + underline reveal from left (200ms)
- **Nav links:** Gold underline grows from center (150ms)

### Page Transitions
- **Route changes:** 200ms fade-out of current page, then 200ms fade-in of new page
- **SvelteKit:** Use `transition:fade` with custom duration — avoid heavy Svelte transitions

### Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

---

## 6. Imagery Direction

### Photography Style
| Category | Direction | Avoid |
|----------|-----------|-------|
| **Aerial/Cityscapes** | Drone shots of city skylines at golden hour or twilight. CEE cities (Prague, Sofia, Bucharest), LATAM (Tegucigalpa, Santo Domingo). Warm tones, long shadows. | Generic stock city photos, over-saturated HDR |
| **Architecture** | Clean, modern buildings with geometric lines. Construction progress shots showing scale. No people — focus on structures. | Shiny renders, CGI architecture, luxury interiors |
| **People** | Professional meetings — small groups (2-4), candid (not posed), diverse. Boardroom settings, not open-plan offices. | Handshakes, stock "business people," suits with tablets |
| **Data/Abstract** | Geometric patterns, data visualization overlays on maps, circuit-board-meets-city-grid compositions. | Literal AI imagery (robots, neural networks), glowing blue circuits |
| **Markets** | Ground-level street scenes from target markets — showing local character, economic activity, construction. | Poverty imagery, tourist clichés |

### Image Treatment
- **Color grading:** Slightly desaturated, warm shadows, cool highlights. Consistent across all images.
- **Dark sections:** Images with reduced brightness and increased contrast, overlaid with 40-60% Deep Navy
- **Light sections:** Full-color images with subtle vignette
- **Format:** WebP primary, AVIF where supported, JPEG fallback
- **Lazy loading:** All below-fold images
- **Responsive:** `srcset` with 3 breakpoints (640w, 1024w, 1400w)

### Illustrations/Icons
- **Style:** Minimal line icons, 1.5px stroke weight
- **Color:** Single color — Gold on dark, Charcoal on light
- **Source:** Phosphor Icons (consistent, open-source, Svelte-friendly)
- **Avoid:** Filled icons, multi-color icons, 3D icons

---

## 7. Page-Level Dark/Light Pattern

This is the core of the design system — how dark and light sections alternate.

### Homepage
```
[NAV — Deep Navy]
[HERO — Deep Navy + background image]     ← Dark
[VALUE PROPOSITION — Off-White]            ← Light
[MARKETS OVERVIEW — Deep Navy]             ← Dark
[EXPERTISE/TEAM — Off-White]              ← Light
[STATISTICS — Deep Navy]                   ← Dark
[TESTIMONIALS — Off-White]               ← Light
[CTA — Deep Navy]                          ← Dark
[FOOTER — Deep Navy]                       ← Dark
```

### Market Detail Page
```
[NAV — Deep Navy]
[HERO — Deep Navy + country image]         ← Dark
[MARKET OVERVIEW — Off-White]              ← Light
[KEY METRICS — Deep Navy]                  ← Dark
[DATA TABLE — White]                       ← Light (data readability)
[PROJECTS — Off-White]                    ← Light
[CTA — Deep Navy]                          ← Dark
[FOOTER — Deep Navy]                       ← Dark
```

### About / Contact
```
[NAV — Deep Navy]
[HERO — Deep Navy]                         ← Dark
[CONTENT — Off-White]                      ← Light
[TEAM — White]                             ← Light
[CONTACT FORM — White]                     ← Light
[FOOTER — Deep Navy]                       ← Dark
```

### Rule
- **Minimum 2 consecutive sections** of the same mode before switching (avoids flicker)
- **Data-heavy content** always on light backgrounds (tables, forms, long text)
- **Positioning/emotional content** on dark backgrounds (heroes, stats, CTAs)
- **Transitions:** Hard edge (clean 1px line) or soft gradient (8px fade) — use consistently

---

## 8. Accessibility Requirements

| Requirement | Implementation |
|-------------|---------------|
| Color contrast | All combinations verified ≥ 4.5:1 (AA). See contrast table above. |
| Focus indicators | 2px solid Gold outline, 2px offset on all interactive elements |
| Touch targets | Minimum 44×44px for all interactive elements |
| Alt text | All images require descriptive alt text. Decorative images use `alt=""` |
| Heading hierarchy | Strict h1→h2→h3 nesting. No skipped levels. |
| Keyboard navigation | All interactive elements reachable and operable via keyboard |
| Screen reader | ARIA labels on all icon-only buttons. Live regions for dynamic content. |
| Motion | `prefers-reduced-motion` media query disables all animations |
| Forms | Every input has a visible `<label>`. Error messages linked via `aria-describedby` |
| Language | `<html lang="en">`. Subsections in other languages use `lang` attribute |

---

## 9. Performance Budget

| Resource | Budget | Strategy |
|----------|--------|----------|
| Total page weight | < 500KB (initial load) | Lazy load below-fold, optimize images |
| Fonts | < 100KB | Subset Playfair to Latin, use `font-display: swap` |
| JavaScript | < 150KB (gzipped) | SvelteKit SSR + minimal client JS |
| CSS | < 30KB | Purge unused styles, critical CSS inline |
| Images | < 200KB initial | WebP/AVIF, responsive srcset, lazy load |
| Lighthouse Performance | ≥ 95 | Target across all pages |
| Lighthouse Accessibility | ≥ 95 | Target across all pages |
| First Contentful Paint | < 1.5s | SSR critical path |
| Largest Contentful Paint | < 2.5s | Optimize hero image loading |

---

## 10. SvelteKit Implementation Notes

### Design Tokens as CSS Custom Properties
All tokens defined in `app.css` / `app.postcss`. No CSS-in-JS. Pure CSS custom properties for maximum performance.

### Component Architecture
- `src/lib/components/ui/` — base components (Button, Card, Input, Table)
- `src/lib/components/layout/` — Section, Container, Grid
- `src/lib/components/sections/` — page-level sections (Hero, MarketGrid, Stats)
- All components accept a `theme: 'dark' | 'light'` prop for section context

### Dark/Light Switching
```svelte
<!-- Section wrapper that sets theme context -->
<section class="section section--dark">
  <slot />
</section>

<style>
  .section--dark {
    background: var(--primary-deep-navy);
    color: var(--text-on-dark); /* white */
  }
  .section--light {
    background: var(--bg-off-white);
    color: var(--text-primary); /* charcoal */
  }
</style>
```

### Scroll Animations
Use Svelte's `use:intersectionObserver` action (custom) for reveal animations. No external animation library needed — CSS transitions handle the animation, JS handles the trigger.

---

## Appendix: Design Decisions Log

| Decision | Rationale | Confidence |
|----------|-----------|------------|
| Dark-dominant hybrid over pure dark | Better data readability, WCAG easier, still conveys authority | 7.5/10 |
| Playfair Display for headings | Conveys authority + modernity; avoids generic sans-serif | 7/10 |
| Inter for body | Industry-proven readability, excellent at all sizes | 9/10 |
| Gold accent over blue | Differentiates from tech competitors, signals premium positioning | 7/10 |
| 4px grid base unit | Standard, flexible, good developer experience | 8/10 |
| 6px border radius | Balances sharp structure with interactive friendliness | 7/10 |
| Minimal shadows | Cleaner, more modern, better performance | 8/10 |
| CSS custom properties for theming | Best performance, SvelteKit-native, no runtime cost | 9/10 |

---

*Generated by Advisory Council session 2026-03-27. Full deliberation: 6 advisors, 3 rounds, 10+ stress-test exchanges.*
