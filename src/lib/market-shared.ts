export type MarketStatus =
  | 'priority'
  | 'priority-upside'
  | 'priority-global'
  | 'active'
  | 'opportunistic'
  | 'watch-active'
  | 'watch'
  | 'watchlist'
  | 'benchmark'
  | 'bonus';

export type MarketConfidence = 'high' | 'medium-high' | 'medium' | 'medium-low' | 'low';

export interface MarketCardData {
  slug: string;
  country: string;
  status: MarketStatus;
  group_label: string;
  priority_rank: number;
  confidence: MarketConfidence;
  summary: {
    market_stage: {
      label: string;
      description: string;
    };
  };
  scorecard: Array<{
    key: string;
    label: string;
    score: number;
  }>;
}

export function formatStatus(status: MarketStatus) {
  return status.replace(/-/g, ' ');
}
