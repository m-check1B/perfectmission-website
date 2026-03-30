<script lang="ts">
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import MarketCard from '$lib/components/MarketCard.svelte';
  import type { MarketStatus } from '$lib/market-shared';
  import Seo from '$lib/components/Seo.svelte';
  import { marketGroups, marketIndex } from '$lib/market-intelligence';

  const publicStatusLegend: Record<string, string> = {
    priority: 'High-priority market with strong current execution potential.',
    'priority-upside': 'High-upside market with stronger return potential and higher execution risk.',
    'priority-global': 'Priority non-European market with strong structural momentum.',
    active: 'Active live market with credible current relevance.',
    opportunistic: 'Selective market where opportunities depend heavily on scope and timing.',
    'watch-active': 'Market worth monitoring where execution conditions remain more demanding.',
    watch: 'Lower-priority market kept under review.',
    watchlist: 'Monitored market rather than an immediate execution market.',
    benchmark: 'Reference market used for comparison and context.',
    bonus: 'Optional market outside the current live set.'
  };
  const statusLegendEntries = Object.entries(marketIndex.status_legend) as [MarketStatus, string][];
</script>

<Seo
  title="Markets | Perfect Mission"
  description="Browse the Perfect Mission market-intelligence index, grouped by region and ranked by execution priority."
  canonicalPath="/markets/"
/>

<div class="page-shell">
  <Header currentPath="/markets/" />

  <main id="main-content" class="section-stack" tabindex="-1">
    <section class="section">
      <div class="container page-intro">
        <p class="eyebrow">Market library</p>
        <h1>All live market-intelligence briefs.</h1>
        <p>
          Browse the live country briefs by region, market priority, and current operating
          profile.
        </p>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container legend-grid">
        {#each statusLegendEntries as [status]}
          <article class="legend-card">
            <strong>{status.replace(/-/g, ' ')}</strong>
            <p>{publicStatusLegend[status] ?? marketIndex.status_legend[status]}</p>
          </article>
        {/each}
      </div>
    </section>

    {#each marketGroups as group}
      <section class="section">
        <div class="container">
          <div class="section-heading">
            <p class="eyebrow">{group.id}</p>
            <h2>{group.label}</h2>
          </div>

          <div class="card-grid">
            {#each group.markets as market}
              <MarketCard {market} />
            {/each}
          </div>
        </div>
      </section>
    {/each}
  </main>

  <Footer />
</div>
