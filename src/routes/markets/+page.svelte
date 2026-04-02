<script lang="ts">
  import MarketCard from '$lib/components/MarketCard.svelte';
  import type { MarketStatus } from '$lib/market-shared';
  import Seo from '$lib/components/Seo.svelte';
  import { SITE_URL, absoluteUrl, buildBreadcrumbSchema } from '$lib/site';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();

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
  const statusLegendEntries = $derived(
    Object.entries(data.statusLegend) as [MarketStatus, string][]
  );
  const allMarkets = $derived(
    data.marketGroups
      .flatMap((group) => group.markets)
      .toSorted((left, right) => left.priority_rank - right.priority_rank)
  );
  const priorityBriefCount = $derived(
    allMarkets.filter((market) => market.status.startsWith('priority')).length
  );
  const lastUpdatedLabel = $derived(formatDateLabel(data.lastUpdated));
  const breadcrumbSchema = buildBreadcrumbSchema([
    { name: 'Home', path: '/' },
    { name: 'Markets', path: '/markets/' }
  ]);
  const collectionSchema = $derived({
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    name: 'Perfect Mission market library',
    description:
      'Browse the Perfect Mission market-intelligence index, grouped by region and ranked by execution priority.',
    url: absoluteUrl('/markets/'),
    inLanguage: 'en-GB',
    dateModified: data.lastUpdated,
    about: {
      '@id': `${SITE_URL}/#organization`
    },
    isPartOf: {
      '@id': `${SITE_URL}/#website`
    },
    mainEntity: {
      '@type': 'ItemList',
      name: 'Live market-intelligence briefs',
      numberOfItems: allMarkets.length,
      itemListOrder: 'https://schema.org/ItemListOrderAscending',
      itemListElement: allMarkets.map((market, index) => ({
        '@type': 'ListItem',
        position: index + 1,
        name: market.country,
        url: absoluteUrl(`/markets/${market.slug}/`)
      }))
    }
  });

  function formatDateLabel(dateString: string) {
    const normalizedDate = dateString.includes('T') ? dateString : `${dateString}T00:00:00Z`;
    const parsedDate = new Date(normalizedDate);

    if (Number.isNaN(parsedDate.getTime())) {
      return dateString;
    }

    return new Intl.DateTimeFormat('en-GB', {
      dateStyle: 'long',
      timeZone: 'UTC'
    }).format(parsedDate);
  }
</script>

<Seo
  title="Markets | Perfect Mission"
  description="Browse the Perfect Mission market-intelligence index, grouped by region and ranked by execution priority."
  canonicalPath="/markets/"
  structuredData={[breadcrumbSchema, collectionSchema]}
/>

<main id="main-content" class="section-stack" tabindex="-1">
    <section class="section">
      <div class="container detail-hero">
        <div class="page-intro">
          <p class="eyebrow">Market library</p>
          <h1>All live market-intelligence briefs.</h1>
          <p>
            Browse the live country briefs by region, market priority, and current operating
            profile.
          </p>
        </div>

        <aside class="detail-summary">
          <div class="detail-summary__row">
            <span>Live briefs</span>
            <strong>{allMarkets.length}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Priority briefs</span>
            <strong>{priorityBriefCount}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Regions covered</span>
            <strong>{data.marketGroups.length}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Updated</span>
            <strong><time datetime={data.lastUpdated}>{lastUpdatedLabel}</time></strong>
          </div>
        </aside>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container legend-grid">
        {#each statusLegendEntries as [status]}
          <article class="legend-card">
            <strong>{status.replace(/-/g, ' ')}</strong>
            <p>{publicStatusLegend[status] ?? data.statusLegend[status]}</p>
          </article>
        {/each}
      </div>
    </section>

    {#each data.marketGroups as group}
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
