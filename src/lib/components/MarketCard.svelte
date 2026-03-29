<script lang="ts">
  import { formatStatus, type MarketDocument } from '$lib/market-intelligence';

  let {
    market,
    featured = false
  }: {
    market: MarketDocument;
    featured?: boolean;
  } = $props();
</script>

<article class:market-card--featured={featured} class="market-card">
  <div class="market-card__meta">
    <span class="eyebrow">{market.group_label}</span>
    <span class="status-chip">{formatStatus(market.status)}</span>
  </div>

  <h3>{market.country}</h3>
  <p class="market-card__subtitle">{market.hero.subtitle}</p>
  <p>{market.summary.one_line_verdict}</p>

  <dl class="market-card__facts">
    <div>
      <dt>Priority</dt>
      <dd>#{market.priority_rank}</dd>
    </div>
    <div>
      <dt>Confidence</dt>
      <dd>{market.confidence}</dd>
    </div>
    <div>
      <dt>Overall fit</dt>
      <dd>{market.scorecard.find((item) => item.key === 'overall_fit')?.score ?? 'n/a'}/10</dd>
    </div>
  </dl>

  <a class="text-link" href={`/markets/${market.slug}/`}>Open market brief</a>
</article>
