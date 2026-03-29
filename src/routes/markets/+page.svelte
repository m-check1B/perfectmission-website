<script lang="ts">
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import MarketCard from '$lib/components/MarketCard.svelte';
  import Seo from '$lib/components/Seo.svelte';
  import { marketGroups, marketIndex } from '$lib/market-intelligence';
</script>

<Seo
  title="Markets | Perfect Mission"
  description="Browse the Perfect Mission market-intelligence index, grouped by region and ranked by execution priority."
  canonicalPath="/markets/"
/>

<div class="page-shell">
  <Header currentPath="/markets/" />

  <main class="section-stack">
    <section class="section">
      <div class="container page-intro">
        <p class="eyebrow">Market library</p>
        <h1>All live market-intelligence briefs.</h1>
        <p>
          The index follows the imported MI pack directly: group structure, priority ranking,
          launch recommendation, and status legend are all source-driven.
        </p>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container legend-grid">
        {#each Object.entries(marketIndex.status_legend) as [status, summary]}
          <article class="legend-card">
            <strong>{status.replace(/-/g, ' ')}</strong>
            <p>{summary}</p>
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
