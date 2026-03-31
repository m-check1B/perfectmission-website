<script lang="ts">
  import { onMount } from 'svelte';
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import MarketCard from '$lib/components/MarketCard.svelte';
  import Seo from '$lib/components/Seo.svelte';
  import { PROFESSIONAL_SERVICE_SCHEMA } from '$lib/site';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();

  let mounted = $state(false);
  
  onMount(() => {
    mounted = true;
    
    // Progressive enhancement: add animation class for JS-enabled browsers
    // Content starts visible (SSR-friendly), animates when scrolled into view
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1, rootMargin: '50px 0px 0px 0px' }
    );
    
    document.querySelectorAll('.reveal-on-scroll').forEach((el) => {
      observer.observe(el);
    });
    
    return () => observer.disconnect();
  });

  const featuredMarkets = $derived(data.featuredMarkets);
  const launchMarkets = $derived(data.launchMarkets);
  const marketGroups = $derived(data.marketGroups);
  const stats = $derived([
    { label: 'Live markets', value: `${data.stats.liveMarkets}` },
    { label: 'Launch markets', value: `${data.stats.launchMarkets}` },
    { label: 'Regions covered', value: `${data.stats.regionsCovered}` }
  ]);
  const heroSignals = [
    'AI-assisted screening',
    '30 years of founder expertise',
    'Cross-border execution focus'
  ];
  const prioritySnapshot = $derived(data.launchMarkets.slice(0, 3));
  const approachPillars = [
    {
      title: 'Screen faster',
      detail:
        'AI-assisted research compresses the first pass on regulation, ownership constraints, supply pipeline, and demand fit.'
    },
    {
      title: 'Rank what matters',
      detail:
        'We compare countries and cities by investor fit, execution friction, and timing rather than headline excitement.'
    },
    {
      title: 'Move with proof',
      detail:
        'Every brief is shaped into a decision-ready document with cited sources, risk flags, and a practical next step.'
    }
  ];
  const founders = [
    {
      name: 'Matej Havlin',
      role: 'Founder',
      summary:
        'Drives AI-enabled market analysis, opportunity filtering, and investor-facing synthesis across live briefs.'
    },
    {
      name: 'Lukas Havel',
      role: 'Founder',
      summary:
        'Brings 30 years of real-estate and execution judgment to underwriting, delivery reality, and market-entry sequencing.'
    }
  ];
  const processSteps = [
    {
      title: 'Screen',
      summary:
        'We narrow the field fast with AI-assisted market screening, regulatory checks, and demand-side filters.'
    },
    {
      title: 'Sequence',
      summary:
        'We rank priority countries and cities by timing, investor fit, and execution practicality rather than headline noise.'
    },
    {
      title: 'Pressure-test',
      summary:
        'We turn the shortlist into a decision-ready brief covering foreign ownership, development friction, and next actions.'
    }
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
  structuredData={PROFESSIONAL_SERVICE_SCHEMA}
/>

<div class="page-shell">
  <Header currentPath="/" />

  <main id="main-content" tabindex="-1">
    <!-- Hero Section -->
    <section class="hero-section">
      <div class="container hero-grid">
        <div class="hero-copyblock" class:animate-in={mounted}>
          <p class="eyebrow">AI-driven real estate consultancy</p>
          <h1>Move on emerging-market real estate before slower capital even clears first review.</h1>
          <p class="hero-copy">
            Perfect Mission helps investors and developers screen markets, sequence entry, and
            pressure-test execution risk with AI-assisted analysis grounded in operator judgment.
            Start with live country briefs, then move into a focused market conversation.
          </p>

          <div class="hero-actions">
            <a
              class="button button--primary"
              href="/markets/"
              onclick={() => captureCta('review_live_briefs', '/markets/')}
            >
              Review live briefs
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style="margin-left: 4px;">
                <path d="M3 8H13M13 8L9 4M13 8L9 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </a>
            <a
              class="button button--secondary"
              href="mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing"
              onclick={() =>
                captureCta(
                  'book_market_conversation',
                  'mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20market%20briefing'
                )}
            >
              Book a market conversation
            </a>
          </div>

          <ul class="hero-signal-list" aria-label="Perfect Mission operating advantages">
            {#each heroSignals as signal}
              <li>{signal}</li>
            {/each}
          </ul>
        </div>

        <div class="hero-panel" class:animate-in={mounted} style="animation-delay: 0.2s;">
          <p class="hero-panel__title">What you get first</p>
          <div class="hero-proof">
            <strong>Decision-ready market brief</strong>
            <p>
              Priority ranking, execution reality, foreign-ownership notes, city focus, and cited
              sources in one review surface.
            </p>
          </div>

          <ol class="launch-list">
            {#each prioritySnapshot as market}
              <li>
                <strong>{market.country}</strong>
                <span>{market.summary.market_stage.label}</span>
              </li>
            {/each}
          </ol>

          <a
            class="text-link hero-panel__link"
            href="mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20priority%20market%20review"
            onclick={() =>
              captureCta(
                'request_priority_market_review',
                'mailto:info@perfectmission.co.uk?subject=Perfect%20Mission%20priority%20market%20review'
              )}
          >
            Request a priority market review
          </a>
        </div>
      </div>
    </section>

    <!-- Approach Section -->
    <section class="section">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Approach and speed</p>
          <h2>Built to cut weeks out of early market selection without lowering the underwriting standard.</h2>
          <p>
            Perfect Mission combines machine-speed screening with founder judgment so investors can
            eliminate weak markets quickly and focus attention where the real edge exists.
          </p>
        </div>

        <div class="approach-grid">
          {#each approachPillars as pillar, i}
            <article class="approach-card reveal-on-scroll" style="animation-delay: {i * 0.08}s;">
              <p class="hero-panel__title">0{i + 1}</p>
              <h3>{pillar.title}</h3>
              <p>{pillar.detail}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="section">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Coverage at a glance</p>
          <h2>Focused coverage across Europe, Latin America, and selected frontier markets.</h2>
        </div>

        <div class="stats-grid">
          {#each stats as stat, i}
            <article class="stat-card reveal-on-scroll" style="animation-delay: {i * 0.1}s;">
              <strong>{stat.value}</strong>
              <span>{stat.label}</span>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <!-- Founders and Process Section -->
    <section class="section section--muted">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Founders and process</p>
          <h2>Operator judgment and a disciplined screening process, not generic market commentary.</h2>
          <p>
            Perfect Mission combines founder-led real estate experience with AI-assisted analysis
            so early market decisions move faster without losing execution realism.
          </p>
        </div>

        <div class="credibility-grid">
          <div class="founder-stack reveal-on-scroll">
            {#each founders as founder, i}
              <article class="profile-card" style="animation-delay: {i * 0.08}s;">
                <p class="eyebrow">{founder.role}</p>
                <h3>{founder.name}</h3>
                <p>{founder.summary}</p>
              </article>
            {/each}
          </div>

          <ol class="process-list reveal-on-scroll" style="animation-delay: 0.12s;">
            {#each processSteps as step, i}
              <li class="process-step">
                <span class="process-step__index">0{i + 1}</span>
                <div>
                  <h3>{step.title}</h3>
                  <p>{step.summary}</p>
                </div>
              </li>
            {/each}
          </ol>
        </div>
      </div>
    </section>

    <!-- Priority Markets Section -->
    <section class="section section--muted">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Priority coverage</p>
          <h2>Markets currently prioritized for immediate attention.</h2>
        </div>

        <div class="card-grid card-grid--featured">
          {#each launchMarkets as market, i}
            <div class="reveal-on-scroll" style="animation-delay: {i * 0.1}s;">
              <MarketCard {market} featured={true} />
            </div>
          {/each}
        </div>
      </div>
    </section>

    <!-- Regional Map Section -->
    <section class="section">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Regional map</p>
          <h2>Regional coverage arranged around the current live market map.</h2>
        </div>

        <div class="group-grid">
          {#each marketGroups as group, i}
            <article class="group-card reveal-on-scroll" style="animation-delay: {i * 0.1}s;">
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

    <!-- Selected Briefs Section -->
    <section class="section section--muted">
      <div class="container">
        <div class="section-heading reveal-on-scroll">
          <p class="eyebrow">Selected briefs</p>
          <h2>High-priority live markets with the strongest current fit.</h2>
        </div>

        <div class="card-grid">
          {#each featuredMarkets as market, i}
            <div class="reveal-on-scroll" style="animation-delay: {i * 0.08}s;">
              <MarketCard {market} />
            </div>
          {/each}
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="section">
      <div class="container">
        <div class="cta-band reveal-on-scroll">
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
      </div>
    </section>

    <!-- Contact Section -->
    <section class="section section--muted" id="contact" aria-labelledby="contact-heading">
      <div class="container contact-grid">
        <div class="section-heading contact-copy reveal-on-scroll">
          <p class="eyebrow">Contact</p>
          <h2 id="contact-heading">Brief us on the market, capital, or site question you need cleared.</h2>
          <p>
            Perfect Mission Ltd provides decision-ready country briefs, launch sequencing, and
            execution screens for cross-border real estate opportunities.
          </p>
        </div>

        <aside class="contact-card reveal-on-scroll" aria-labelledby="contact-card-title" style="animation-delay: 0.15s;">
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
