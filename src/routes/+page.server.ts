import { launchMarkets, marketGroups, markets } from '$lib/market-intelligence';
import type { MarketCardData } from '$lib/market-shared';

export const prerender = true;

function toMarketCardData(market: (typeof markets)[number]): MarketCardData {
  return {
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
  };
}

export function load() {
  return {
    featuredMarkets: markets.filter((market) => market.priority_rank <= 6).map(toMarketCardData),
    launchMarkets: launchMarkets.map(toMarketCardData),
    marketGroups: marketGroups.map((group) => ({
      id: group.id,
      label: group.label,
      count_live: group.count_live,
      markets: group.markets.map((market) => ({
        slug: market.slug,
        country: market.country,
        summary: {
          market_stage: {
            label: market.summary.market_stage.label
          }
        }
      }))
    })),
    stats: {
      liveMarkets: markets.length,
      launchMarkets: launchMarkets.length,
      regionsCovered: marketGroups.length
    }
  };
}
