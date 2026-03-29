<script lang="ts">
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import MarketCard from '$lib/components/MarketCard.svelte';
  import Seo from '$lib/components/Seo.svelte';
  import { launchMarkets, marketGroups, markets } from '$lib/market-intelligence';

  const featuredMarkets = markets.filter((market) => market.priority_rank <= 6);
  const stats = [
    { label: 'Live markets', value: `${markets.length}` },
    { label: 'Launch markets', value: `${launchMarkets.length}` },
    { label: 'Regions covered', value: `${marketGroups.length}` }
  ];

  function captureCta(label: string, destination: string) {
    window.posthog?.capture('cta_click', {
      site: 'perfectmission.co.uk',
      pathname: '/',
      label,
      destination
    });
  }
</script>

<Seo
  title="Perfect Mission | Market intelligence for cross-border real estate"
  description="Perfect Mission turns emerging-market real estate intelligence into decision-ready country briefs, launch priorities, and execution screens."
  canonicalPath="/"
/>

<div class="page-shell">
  <Header currentPath="/" />

  <main>
    <section class="hero-section">
      <div class="container hero-grid">
        <div>
          <p class="eyebrow">Cross-border market intelligence</p>
          <h1>Cross-border real estate briefs built for faster decisions.</h1>
          <p class="hero-copy">
            Perfect Mission provides structured country briefs across 14 live markets, combining
            execution signals, comparative scoring, and cited sources for cross-border real estate
            decisions.
          </p>

          <div class="hero-actions">
            <a
              class="button button--primary"
              href="/markets/"
              onclick={() => captureCta('browse_all_markets', '/markets/')}
            >
              Browse all markets
            </a>
            <a
              class="button button--secondary"
              href="mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing"
              onclick={() =>
                captureCta(
                  'request_briefing',
                  'mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing'
                )}
            >
              Request a briefing
            </a>
          </div>
        </div>

        <div class="hero-panel">
          <p class="hero-panel__title">Priority markets</p>
          <ol class="launch-list">
            {#each launchMarkets as market}
              <li>
                <strong>{market.country}</strong>
                <span>{market.summary.market_stage.label}</span>
              </li>
            {/each}
          </ol>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Coverage at a glance</p>
          <h2>Focused coverage across Europe, Latin America, and selected frontier markets.</h2>
        </div>

        <div class="stats-grid">
          {#each stats as stat}
            <article class="stat-card">
              <strong>{stat.value}</strong>
              <span>{stat.label}</span>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Priority coverage</p>
          <h2>Markets currently prioritized for immediate attention.</h2>
        </div>

        <div class="card-grid card-grid--featured">
          {#each launchMarkets as market}
            <MarketCard {market} featured={true} />
          {/each}
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Regional map</p>
          <h2>Regional coverage arranged around the current live market map.</h2>
        </div>

        <div class="group-grid">
          {#each marketGroups as group}
            <article class="group-card">
              <div class="group-card__header">
                <h3>{group.label}</h3>
                <span>{group.count_live} live</span>
              </div>

              <ul>
                {#each group.markets as market}
                  <li>
                    <a href={`/markets/${market.slug}/`}>{market.country}</a>
                    <small>{market.summary.market_stage.label}</small>
                  </li>
                {/each}
              </ul>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section class="section section--muted">
      <div class="container">
        <div class="section-heading">
          <p class="eyebrow">Selected briefs</p>
          <h2>High-priority live markets with the strongest current fit.</h2>
        </div>

        <div class="card-grid">
          {#each featuredMarkets as market}
            <MarketCard {market} />
          {/each}
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container cta-band">
        <div>
          <p class="eyebrow">Need a brief?</p>
          <h2>Start with a focused market conversation.</h2>
          <p>
            Each country page includes comparative scoring, strategy fit, development reality,
            foreign-ownership notes, city priorities, and cited sources.
          </p>
        </div>

        <div class="hero-actions">
          <a
            class="button button--primary"
            href="/markets/"
            onclick={() => captureCta('enter_market_library', '/markets/')}
          >
            Enter the market library
          </a>
          <a
            class="button button--secondary"
            href="mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20verified%20market%20memo"
            onclick={() =>
              captureCta(
                'request_verified_memo',
                'mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20verified%20market%20memo'
              )}
          >
            Request a verified memo
          </a>
        </div>
      </div>
    </section>

    <section class="section section--muted" id="contact">
      <div class="container contact-grid">
        <div class="section-heading contact-copy">
          <p class="eyebrow">Contact</p>
          <h2>Brief us on the market, capital, or site question you need cleared.</h2>
          <p>
            Perfect Mission Ltd provides decision-ready country briefs, launch sequencing, and
            execution screens for cross-border real estate opportunities.
          </p>
        </div>

        <aside class="contact-card" aria-labelledby="contact-card-title">
          <p class="hero-panel__title" id="contact-card-title">Direct line</p>
          <a class="contact-card__email" href="mailto:info@perfectmission.co.uk">
            info@perfectmission.co.uk
          </a>
          <p>20 Wenlock Road, London N1 7GU, United Kingdom</p>
          <p>Registered in England &amp; Wales, No. 08651715</p>

          <div class="hero-actions contact-card__actions">
            <a
              class="button button--primary"
              href="mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing"
              onclick={() =>
                captureCta(
                  'email_contact_section',
                  'mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing'
                )}
            >
              Email Perfect Mission
            </a>
            <a
              class="button button--secondary"
              href="/markets/"
              onclick={() => captureCta('contact_section_browse_markets', '/markets/')}
            >
              Review live briefs
            </a>
          </div>
        </aside>
      </div>
    </section>
  </main>

  <Footer />
</div>
