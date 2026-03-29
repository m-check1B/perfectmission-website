<script lang="ts">
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import ScoreBar from '$lib/components/ScoreBar.svelte';
  import Seo from '$lib/components/Seo.svelte';
  import { buildBriefMailto, formatStatus } from '$lib/market-intelligence';
  import { buildBreadcrumbSchema } from '$lib/site';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
  const market = $derived(data.market);
  const structuredData = $derived([
    {
      '@context': 'https://schema.org',
      '@type': 'Report',
      name: market.seo.title,
      description: market.seo.description,
      url: `https://perfectmission.co.uk/markets/${market.slug}/`,
      dateModified: market.last_updated,
      about: {
        '@type': 'Place',
        name: market.country
      }
    },
    buildBreadcrumbSchema([
      { name: 'Perfect Mission', path: '/' },
      { name: 'Markets', path: '/markets/' },
      { name: market.country, path: `/markets/${market.slug}/` }
    ])
  ]);
  const primaryCta = $derived(
    buildBriefMailto(
      `${market.country} market brief`,
      `Please send the verified ${market.country} market memo and next steps.`
    )
  );
  const secondaryCta = $derived(
    buildBriefMailto(
      `${market.country} market thesis`,
      `I want to discuss a site, listing, plot, or thesis in ${market.country}.`
    )
  );
</script>

<Seo
  title={market.seo.title}
  description={market.seo.description}
  canonicalPath={`/markets/${market.slug}/`}
  structuredData={structuredData}
  modifiedTime={market.last_updated}
/>

<div class="page-shell">
  <Header currentPath="/markets/" />

  <main class="section-stack">
    <section class="hero-section hero-section--detail">
      <div class="container detail-hero">
        <div>
          <nav aria-label="Breadcrumb" class="breadcrumb">
            <a href="/">Perfect Mission</a>
            <span aria-hidden="true">/</span>
            <a href="/markets/">Markets</a>
            <span aria-hidden="true">/</span>
            <span aria-current="page">{market.country}</span>
          </nav>

          <p class="eyebrow">{market.hero.eyebrow}</p>
          <h1>{market.hero.title}</h1>
          <p class="hero-copy">{market.hero.subtitle}</p>

          <div class="hero-actions">
            <a class="button button--primary" href={primaryCta}>{market.cta.primary}</a>
            <a class="button button--secondary" href={secondaryCta}>{market.cta.secondary}</a>
          </div>
        </div>

        <aside class="detail-summary">
          <div class="detail-summary__row">
            <span>Status</span>
            <strong>{formatStatus(market.status)}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Priority rank</span>
            <strong>#{market.priority_rank}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Confidence</span>
            <strong>{market.confidence}</strong>
          </div>
          <div class="detail-summary__row">
            <span>Updated</span>
            <strong><time datetime={market.last_updated}>{market.last_updated}</time></strong>
          </div>
        </aside>
      </div>
    </section>

    <section class="section">
      <div class="container narrative-grid">
        <article class="panel panel--accent">
          <p class="eyebrow">Market stage</p>
          <h2>{market.summary.market_stage.label}</h2>
          <p>{market.summary.market_stage.description}</p>
        </article>

        <article class="panel">
          <p class="eyebrow">Overview</p>
          <p>{market.development_reality.copy}</p>
          <p class="eyebrow">Foreign ownership</p>
          <p>{market.foreign_ownership.summary}</p>
        </article>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container two-column">
        <div>
          <div class="section-heading">
            <p class="eyebrow">Scorecard</p>
            <h2>Comparative scorecard across the current market set.</h2>
          </div>

          <div class="score-list">
            {#each market.scorecard as item}
              <ScoreBar
                label={item.key === 'overall_fit' ? 'Overall market fit' : item.label}
                score={item.score}
              />
            {/each}
          </div>
        </div>

        <div>
          <div class="section-heading">
            <p class="eyebrow">Quick facts</p>
            <h2>Key signals and current market facts.</h2>
          </div>

          <dl class="fact-list">
            {#each market.quick_facts as fact}
              <div>
                <dt>{fact.label}</dt>
                <dd>{fact.value}</dd>
              </div>
            {/each}
          </dl>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container two-column">
        <article>
          <div class="section-heading">
            <p class="eyebrow">Strategy fit</p>
            <h2>Where the market is strong, medium, or weak.</h2>
          </div>

          <div class="stack-list">
            {#each market.strategy_fit as fit}
              <article class="stack-card">
                <div class="stack-card__header">
                  <h3>{fit.strategy}</h3>
                  <span class="status-chip">{fit.fit}</span>
                </div>
                <p>{fit.why}</p>
              </article>
            {/each}
          </div>
        </article>

        <article>
          <div class="section-heading">
            <p class="eyebrow">Development reality</p>
            <h2>{market.development_reality.headline}</h2>
          </div>

          <div class="panel">
            <p>{market.development_reality.copy}</p>

            <dl class="micro-grid">
              <div>
                <dt>Permit friction</dt>
                <dd>{market.development_reality.permit_friction}</dd>
              </div>
              <div>
                <dt>Title reliability</dt>
                <dd>{market.development_reality.title_reliability}</dd>
              </div>
              <div>
                <dt>Utilities</dt>
                <dd>{market.development_reality.utilities}</dd>
              </div>
            </dl>
          </div>

          <div class="list-columns">
            <div class="panel">
              <h3>Best entries</h3>
              <ul>
                {#each market.development_reality.best_entries as item}
                  <li>{item}</li>
                {/each}
              </ul>
            </div>

            <div class="panel">
              <h3>Avoid first</h3>
              <ul>
                {#each market.development_reality.avoid_first as item}
                  <li>{item}</li>
                {/each}
              </ul>
            </div>
          </div>
        </article>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container two-column">
        <article>
          <div class="section-heading">
            <p class="eyebrow">Foreign ownership</p>
            <h2>Capital-access summary.</h2>
          </div>

          <div class="panel">
            <p>{market.foreign_ownership.summary}</p>
            <p><strong>Caution:</strong> {market.foreign_ownership.caution}</p>
          </div>

          <div class="section-heading">
            <p class="eyebrow">Lifestyle base</p>
            <h2>{market.lifestyle_base.rating}</h2>
          </div>

          <div class="panel">
            <p>{market.lifestyle_base.copy}</p>
            <dl class="micro-grid">
              <div>
                <dt>Connectivity</dt>
                <dd>{market.lifestyle_base.connectivity}</dd>
              </div>
              <div>
                <dt>Climate</dt>
                <dd>{market.lifestyle_base.climate}</dd>
              </div>
              <div>
                <dt>Home-office fit</dt>
                <dd>{market.lifestyle_base.home_office_fit}</dd>
              </div>
            </dl>
          </div>
        </article>

        <article>
          <div class="section-heading">
            <p class="eyebrow">Priority cities</p>
            <h2>City-level briefs and watchouts.</h2>
          </div>

          <div class="stack-list">
            {#each market.priority_cities as city}
              <article class="stack-card">
                <div class="stack-card__header">
                  <h3>{city.city}</h3>
                  <span>{city.role}</span>
                </div>
                <p>{city.thesis}</p>
                <p><strong>Good for:</strong> {city.good_for.join(', ')}</p>
                <p><strong>Watchouts:</strong> {city.watchouts.join(', ')}</p>
              </article>
            {/each}
          </div>
        </article>
      </div>
    </section>

    <section class="section">
      <div class="container two-column">
        <article class="panel">
          <div class="section-heading">
            <p class="eyebrow">Catalysts</p>
            <h2>Why the market can move.</h2>
          </div>
          <ul>
            {#each market.catalysts as catalyst}
              <li>{catalyst}</li>
            {/each}
          </ul>
        </article>

        <article class="panel">
          <div class="section-heading">
            <p class="eyebrow">Risks</p>
            <h2>What can break the thesis.</h2>
          </div>
          <ul>
            {#each market.risks as risk}
              <li>{risk}</li>
            {/each}
          </ul>
        </article>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Sources</p>
          <h2>Registry carried inside the MI document.</h2>
        </div>

        <div class="stack-list">
          {#each market.source_registry as source}
            <article class="stack-card">
              <div class="stack-card__header">
                <h3>{source.title}</h3>
                <span>{source.publisher}</span>
              </div>
              <p>{source.why_it_matters}</p>
              <p><strong>Retrieved:</strong> {source.retrieved}</p>
              <a class="text-link" href={source.url} target="_blank" rel="noreferrer">Open source</a>
            </article>
          {/each}
        </div>
      </div>
    </section>
  </main>

  <Footer />
</div>
