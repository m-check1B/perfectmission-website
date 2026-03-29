# Perfect Mission MI Pack v1

Build-ready market-intelligence content package for the current Perfect Mission prototype.

## What is included

- `mi.schema.json` — JSON schema for country MI documents
- `markets.index.mi.json` — master index, grouping, launch order, and render rules
- `countries/*.mi.json` — one market-intelligence document per live market on the site
- `optional/georgia.mi.json` — bonus market file for Georgia
- `features/cross-border-investment-verifier.mi.json` — feature-spec file for the verifier agent

## Live-market coverage in this pack

The package covers the 14 markets currently shown on the site:

- Bulgaria
- Romania
- Albania
- Morocco
- Czech Republic
- Poland
- Moldova
- Vietnam
- Panama
- Dominican Republic
- Belize
- Honduras
- Bolivia
- Cuba

## Recommended launch order

1. Bulgaria
2. Romania
3. Morocco
4. Albania

## Intended ingestion model

Each `*.mi.json` file is a self-contained country page object with:

- SEO block
- hero copy
- one-line verdict
- scorecard
- quick facts
- strategy-fit matrix
- development reality
- foreign-ownership summary
- priority cities
- catalysts
- risks
- lifestyle/base notes
- CTA copy
- source registry

## Suggested frontend flow

- `/markets` uses `markets.index.mi.json`
- `/markets/[slug]` pulls the corresponding file from `countries/`
- badges, rankings, and filters can read:
  - `status`
  - `priority_rank`
  - `confidence`
  - `tags`
  - `live_on_site`

## Notes

- The files are content-first, not database-normalized.
- Every country file keeps its own source registry so the frontend or admin layer can expose “last updated”, “confidence”, and source counts without extra joins.
- Some frontier markets intentionally carry lower confidence and stronger risk wording where official data is thin or market execution is restricted.
- Cuba is included because it is on the live site, but the file is tagged as `watchlist` rather than immediately executable.
- Georgia is included as a bonus optional market because it came up in strategy discussion, but it is not on the current live site.

## Suggested next build step

Use Bulgaria as the reference page implementation and wire the frontend components around that file first. Once the template renders correctly, the rest of the country files can be plugged in with the same component structure.