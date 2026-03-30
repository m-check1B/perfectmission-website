import rawIndex from '$lib/content/mi/markets.index.mi.json';
import type { MarketConfidence, MarketStatus } from '$lib/market-shared';

export type { MarketCardData, MarketConfidence, MarketStatus } from '$lib/market-shared';

export interface MarketIndexMarketRef {
  slug: string;
  status: MarketStatus;
  priority_rank: number;
}

export interface MarketIndexGroup {
  id: string;
  label: string;
  count_live: number;
  markets: MarketIndexMarketRef[];
}

export interface MarketIndexDocument {
  schema_version: string;
  document_type: 'market-intelligence-index';
  last_updated: string;
  language: string;
  site_source: string;
  market_count_live: number;
  launch_recommendation: string[];
  status_legend: Record<MarketStatus, string>;
  render_rules: Record<string, string>;
  groups: MarketIndexGroup[];
  optional_additions: Array<{
    slug: string;
    status: MarketStatus;
    reason: string;
  }>;
}

export interface MarketCountryDocument {
  schema_version: string;
  document_type: 'market-intelligence-country';
  last_updated: string;
  language: string;
  country_code: string;
  country: string;
  slug: string;
  region: string;
  status: MarketStatus;
  live_on_site: boolean;
  confidence: MarketConfidence;
  tags?: string[];
  priority_rank?: number;
  section_order?: string[];
  seo: {
    title: string;
    description: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    subtitle: string;
    cta_primary: string;
    cta_secondary: string;
  };
  summary: {
    one_line_verdict: string;
    market_stage: {
      label: string;
      description: string;
    };
    operator_angle: string;
    investor_angle: string;
    base_case: string;
  };
  scorecard: Array<{
    key: string;
    label: string;
    score: number;
  }>;
  quick_facts: Array<{
    label: string;
    value: string;
    source_ref: string;
    note?: string;
  }>;
  strategy_fit: Array<{
    strategy: string;
    fit: 'strong' | 'medium' | 'weak';
    why: string;
  }>;
  development_reality: {
    headline: string;
    copy: string;
    permit_friction: string;
    title_reliability: string;
    utilities: string;
    best_entries: string[];
    avoid_first: string[];
    process_notes: string[];
    source_refs: string[];
  };
  foreign_ownership: {
    summary: string;
    caution: string;
    source_refs: string[];
  };
  priority_cities: Array<{
    city: string;
    role: string;
    thesis: string;
    good_for: string[];
    watchouts: string[];
  }>;
  catalysts: string[];
  risks: string[];
  lifestyle_base: {
    rating: string;
    copy: string;
    connectivity: string;
    climate: string;
    home_office_fit: string;
  };
  cta: {
    headline: string;
    body: string;
    primary: string;
    secondary: string;
  };
  source_registry: Array<{
    id: string;
    title: string;
    url: string;
    publisher: string;
    type: string;
    why_it_matters: string;
    retrieved: string;
  }>;
}

export interface MarketDocument extends MarketCountryDocument {
  priority_rank: number;
  group_id: string;
  group_label: string;
  launch_recommended: boolean;
  status_summary: string;
}

const countryModules = import.meta.glob('./content/mi/countries/*.mi.json', {
  eager: true,
  import: 'default'
}) as Record<string, MarketCountryDocument>;

export const marketIndex = rawIndex as MarketIndexDocument;

const marketMetaBySlug = new Map(
  marketIndex.groups.flatMap((group) =>
    group.markets.map((market) => [
      market.slug,
      {
        group_id: group.id,
        group_label: group.label,
        priority_rank: market.priority_rank,
        status: market.status
      }
    ])
  )
);

const marketDocuments = Object.values(countryModules)
  .map((document) => {
    const meta = marketMetaBySlug.get(document.slug);

    if (!meta) {
      return null;
    }

    return {
      ...document,
      status: meta.status,
      priority_rank: meta.priority_rank,
      group_id: meta.group_id,
      group_label: meta.group_label,
      launch_recommended: marketIndex.launch_recommendation.includes(document.slug),
      status_summary: marketIndex.status_legend[meta.status]
    } satisfies MarketDocument;
  })
  .filter((document): document is MarketDocument => Boolean(document))
  .sort((left, right) => left.priority_rank - right.priority_rank);

export const markets = marketDocuments.filter((market) => market.live_on_site);
export const marketsBySlug = new Map(markets.map((market) => [market.slug, market]));
export const marketSlugs = markets.map((market) => market.slug);
export const launchMarkets = marketIndex.launch_recommendation
  .map((slug) => marketsBySlug.get(slug))
  .filter((market): market is MarketDocument => Boolean(market));

export const marketGroups = marketIndex.groups.map((group) => ({
  ...group,
  markets: group.markets
    .map((market) => marketsBySlug.get(market.slug))
    .filter((market): market is MarketDocument => Boolean(market))
}));

export function getMarketBySlug(slug: string) {
  return marketsBySlug.get(slug);
}

export function buildBriefMailto(subject: string, body: string) {
  const params = new URLSearchParams({
    subject,
    body
  });

  return `mailto:info@perfectmission.co.uk?${params.toString()}`;
}
