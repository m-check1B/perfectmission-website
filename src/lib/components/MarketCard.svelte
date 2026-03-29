<script lang="ts">
  import { formatStatus, type MarketDocument } from '$lib/market-intelligence';

  let {
    market,
    featured = false
  }: {
    market: MarketDocument;
    featured?: boolean;
  } = $props();
  
  function handleClick() {
    window.posthog?.capture('market_card_click', {
      site: 'perfectmission.co.uk',
      country: market.country,
      slug: market.slug,
      featured
    });
  }
</script>

<article class:market-card--featured={featured} class="market-card">
  <a 
    href={`/markets/${market.slug}/`} 
    class="market-card__link"
    onclick={handleClick}
    aria-label={`View market brief for ${market.country}`}
  >
    <div class="market-card__meta">
      <span class="eyebrow">{market.group_label}</span>
      <span class="status-chip">{formatStatus(market.status)}</span>
    </div>

    <h3>{market.country}</h3>
    <p class="market-card__description">{market.summary.market_stage.description}</p>

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
        <dt>Overall score</dt>
        <dd>{market.scorecard.find((item) => item.key === 'overall_fit')?.score ?? 'n/a'}/10</dd>
      </div>
    </dl>

    <span class="market-card__cta">
      Open market brief
      <svg width="14" height="14" viewBox="0 0 16 16" fill="none" class="market-card__arrow">
        <path d="M3 8H13M13 8L9 4M13 8L9 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </span>
  </a>
</article>

<style>
  .market-card {
    position: relative;
    overflow: hidden;
  }
  
  .market-card__link {
    display: block;
    text-decoration: none;
    color: inherit;
  }
  
  .market-card__link:focus {
    outline: none;
  }
  
  .market-card__link:focus-visible {
    outline: 2px solid var(--color-accent);
    outline-offset: 2px;
    border-radius: var(--radius-xl);
  }
  
  .market-card h3 {
    font-size: 1.5rem;
    margin: 0.5rem 0;
    color: var(--color-text);
    transition: color var(--transition-fast);
  }
  
  .market-card:hover h3 {
    color: var(--color-accent-soft);
  }
  
  .market-card__description {
    margin: 0 0 1rem;
    line-height: 1.6;
  }
  
  .market-card__cta {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--color-accent-soft);
    font-weight: 500;
    text-decoration: underline;
    text-decoration-color: rgba(209, 168, 93, 0.4);
    text-underline-offset: 0.2em;
    transition: all var(--transition-fast);
    margin-top: 0.5rem;
  }
  
  .market-card:hover .market-card__cta {
    text-decoration-color: var(--color-accent);
    color: var(--color-accent);
  }
  
  .market-card__arrow {
    transition: transform var(--transition-fast);
  }
  
  .market-card:hover .market-card__arrow {
    transform: translateX(4px);
  }
  
  /* Hover glow effect */
  .market-card::before {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(600px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(232, 184, 92, 0.06), transparent 40%);
    opacity: 0;
    transition: opacity var(--transition-base);
    pointer-events: none;
  }
  
  .market-card:hover::before {
    opacity: 1;
  }
  
  /* Featured card accent line animation */
  .market-card--featured::after {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--color-accent), transparent);
    animation: shimmer 3s infinite;
  }
  
  @keyframes shimmer {
    0% { left: -100%; }
    50%, 100% { left: 100%; }
  }
</style>
