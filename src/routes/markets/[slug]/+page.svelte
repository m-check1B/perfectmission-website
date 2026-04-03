<script lang="ts">
  import { onMount, tick } from 'svelte';
  import ScoreBar from '$lib/components/ScoreBar.svelte';
  import Seo from '$lib/components/Seo.svelte';
  import { buildBriefMailto } from '$lib/contact';
  import { formatStatus } from '$lib/market-shared';
  import {
    buildSourceItemIds,
    getLegacySourceIndex,
    shouldRevealLegacySourceHash
  } from '$lib/market-source-anchors';
  import { COOKIE_BANNER_CLOSED_EVENT } from '$lib/cookie-consent-state';
  import { needsConsentBanner } from '$lib/posthog';
  import { DEFAULT_OG_IMAGE, absoluteUrl, buildBreadcrumbSchema } from '$lib/site';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
  type MarketSource = PageData['market']['source_registry'][number];
  const market = $derived(data.market);
  const marketPath = $derived(`/markets/${market.slug}/`);
  const marketUrl = $derived(absoluteUrl(marketPath));
  const structuredData = $derived([
    {
      '@context': 'https://schema.org',
      '@type': 'Report',
      '@id': `${marketUrl}#report`,
      headline: market.hero.title,
      name: market.seo.title,
      description: market.seo.description,
      url: marketUrl,
      mainEntityOfPage: {
        '@id': marketUrl
      },
      isPartOf: {
        '@id': 'https://perfectmission.co.uk/#website'
      },
      dateModified: market.last_updated,
      inLanguage: 'en-GB',
      image: absoluteUrl(DEFAULT_OG_IMAGE),
      author: {
        '@id': 'https://perfectmission.co.uk/#organization'
      },
      publisher: {
        '@id': 'https://perfectmission.co.uk/#organization'
      },
      about: {
        '@type': 'Place',
        name: market.country
      },
      citation: market.source_registry.map((source) => source.url)
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
  const marketDateFormatter = new Intl.DateTimeFormat('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC'
  });
  const sourcesSectionId = 'market-sources';
  const sourcesSectionHeadingId = 'market-sources-heading';
  const sourceItemIdPrefix = 'market-source-';
  const sourceCount = $derived(market.source_registry.length);
  const sourceItemIds = $derived(buildSourceItemIds(market.source_registry));
  const latestSourceRetrieved = $derived(
    market.source_registry.reduce(
      (latest, source) => (source.retrieved > latest ? source.retrieved : latest),
      ''
    )
  );
  const latestSourceMatchCount = $derived(
    latestSourceRetrieved
      ? market.source_registry.filter((source) => source.retrieved === latestSourceRetrieved).length
      : 0
  );
  const hasSingleLatestSource = $derived(latestSourceMatchCount === 1);
  const latestSourceIndex = $derived(
    hasSingleLatestSource
      ? market.source_registry.findIndex((source) => source.retrieved === latestSourceRetrieved)
      : -1
  );
  const latestSourceId = $derived(
    latestSourceIndex >= 0 ? sourceItemIds[latestSourceIndex] : sourcesSectionId
  );
  const latestSourceRetrievedLabel = $derived(
    latestSourceRetrieved ? formatIsoDate(latestSourceRetrieved) : ''
  );
  const latestSourceSummaryLabel = $derived(
    hasSingleLatestSource ? 'Latest source' : 'Latest refresh'
  );
  const latestSourceAriaLabel = $derived(
    hasSingleLatestSource
      ? `Jump to latest cited source (${latestSourceRetrievedLabel})`
      : `Jump to sources refreshed on ${latestSourceRetrievedLabel} (${latestSourceMatchCount} cited source${latestSourceMatchCount === 1 ? '' : 's'})`
  );

  function formatIsoDate(value: string) {
    const [year, month, day] = value.split('-').map(Number);

    if (!year || !month || !day) {
      return value;
    }

    return marketDateFormatter.format(new Date(Date.UTC(year, month - 1, day)));
  }

  function formatSourceType(value: string) {
    return value
      .split('-')
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' ');
  }

  function getLegacySourceTarget(hash: string) {
    const legacyIndex = getLegacySourceIndex(hash, sourceItemIdPrefix);
    if (legacyIndex === null) {
      return null;
    }

    if (!market.source_registry[legacyIndex]) {
      return null;
    }

    const stableTargetId = sourceItemIds[legacyIndex];
    if (!stableTargetId) {
      return null;
    }

    const stableTarget = document.getElementById(stableTargetId);

    return stableTarget instanceof HTMLDetailsElement ? stableTarget : null;
  }

  function syncStableSourceHash(hash: string, targetId: string) {
    const currentTargetId = hash.startsWith('#') ? hash.slice(1) : hash;

    if (currentTargetId === targetId) {
      return;
    }

    const nextUrl = new URL(window.location.href);
    nextUrl.hash = targetId;
    window.history.replaceState(window.history.state, '', nextUrl);
  }

  async function revealLegacySourceFromHash() {
    const hash = window.location.hash;

    if (
      !shouldRevealLegacySourceHash(
        hash,
        marketPath,
        document.body.dataset.cookieBannerOpen === 'true' || needsConsentBanner(),
        sourceItemIdPrefix
      )
    ) {
      return;
    }

    await tick();

    const target = getLegacySourceTarget(hash);

    if (!target) {
      return;
    }

    syncStableSourceHash(hash, target.id);
    const targetWasClosed = !target.open;
    target.open = true;

    if (targetWasClosed) {
      await tick();
    }

    target.scrollIntoView({ block: 'start' });
    const focusTarget = target.querySelector<HTMLElement>('summary') ?? target;
    focusTarget.focus({ preventScroll: true });
  }

  onMount(() => {
    void revealLegacySourceFromHash();

    const handleHashChange = () => {
      void revealLegacySourceFromHash();
    };
    const handleCookieBannerClosed = () => {
      void revealLegacySourceFromHash();
    };

    window.addEventListener('hashchange', handleHashChange);
    window.addEventListener(COOKIE_BANNER_CLOSED_EVENT, handleCookieBannerClosed);

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
      window.removeEventListener(COOKIE_BANNER_CLOSED_EVENT, handleCookieBannerClosed);
    };
  });

  const formattedLastUpdated = $derived(formatIsoDate(market.last_updated));
</script>

<Seo
  title={market.seo.title}
  description={market.seo.description}
  type="article"
  canonicalPath={marketPath}
  structuredData={structuredData}
  modifiedTime={market.last_updated}
/>

<main id="main-content" class="section-stack" tabindex="-1">
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
            <span>Cited sources</span>
            <strong>
              <a
                class="detail-summary__link"
                href={`#${sourcesSectionId}`}
                aria-label={`Jump to sources section (${sourceCount} cited source${sourceCount === 1 ? '' : 's'})`}
              >
                {sourceCount}
              </a>
            </strong>
          </div>
          <div class="detail-summary__row">
            <span>{latestSourceSummaryLabel}</span>
            <strong>
              {#if latestSourceRetrieved}
                <a
                  class="detail-summary__link"
                  href={`#${latestSourceId}`}
                  aria-label={latestSourceAriaLabel}
                >
                  <time datetime={latestSourceRetrieved}>{latestSourceRetrievedLabel}</time>
                </a>
              {:else}
                Not listed
              {/if}
            </strong>
          </div>
          <div class="detail-summary__row">
            <span>Updated</span>
            <strong><time datetime={market.last_updated}>{formattedLastUpdated}</time></strong>
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

    <section
      id={sourcesSectionId}
      class="section section--muted"
      aria-labelledby={sourcesSectionHeadingId}
    >
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Sources</p>
          <h2 id={sourcesSectionHeadingId}>Expandable citations carried inside the MI document.</h2>
          <p class="source-summary">
            {sourceCount} cited source{sourceCount === 1 ? '' : 's'} in the registry.
            {#if latestSourceRetrieved}
              Latest source refresh
              <time datetime={latestSourceRetrieved}>{latestSourceRetrievedLabel}</time>.
            {/if}
          </p>
        </div>

        <ol class="source-endnotes">
          {#each market.source_registry as source, index}
            <li>
              <details
                id={sourceItemIds[index]}
                class="source-disclosure"
                tabindex="-1"
              >
                <summary>
                  <span class="source-disclosure__index" aria-hidden="true">{index + 1}.</span>
                  <span class="source-disclosure__copy">
                    <span class="source-disclosure__title">{source.title}</span>
                    <span class="source-disclosure__meta">
                      {source.publisher} · {formatSourceType(source.type)}
                    </span>
                  </span>
                  <span class="source-disclosure__indicator" aria-hidden="true">+</span>
                </summary>

                <div class="source-disclosure__body">
                  <p>{source.why_it_matters}</p>
                  <p class="source-disclosure__supporting">
                    Retrieved <time datetime={source.retrieved}>{formatIsoDate(source.retrieved)}</time>
                  </p>
                  <a
                    class="text-link"
                    href={source.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={`Open source: ${source.title} (opens in a new tab)`}
                  >
                    Open source
                  </a>
                </div>
              </details>
            </li>
          {/each}
        </ol>
      </div>
    </section>
  </main>
