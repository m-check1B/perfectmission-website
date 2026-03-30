import { marketGroups, marketIndex } from '$lib/market-intelligence';

export const prerender = true;

export function load() {
  return {
    statusLegend: marketIndex.status_legend,
    marketGroups: marketGroups.map((group) => ({
      id: group.id,
      label: group.label,
      markets: group.markets.map((market) => ({
        slug: market.slug,
        country: market.country,
        status: market.status,
        group_label: market.group_label,
        priority_rank: market.priority_rank,
        confidence: market.confidence,
        summary: {
          market_stage: {
            label: market.summary.market_stage.label,
            description: market.summary.market_stage.description
          }
        },
        scorecard: market.scorecard
      }))
    }))
  };
}
