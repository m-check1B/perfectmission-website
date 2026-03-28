<script lang="ts">
  const navLinks = [
    { href: '#approach', label: 'Approach' },
    { href: '#markets', label: 'Markets' },
    { href: '#founders', label: 'Founders' },
    { href: '#process', label: 'Process' }
  ];

  const statHighlights = [
    { value: '14', label: 'Markets covered' },
    { value: '30+', label: 'Years of founder expertise' },
    { value: '5x', label: 'Faster to decision' }
  ];

  const approachPillars = [
    {
      kicker: 'Signal',
      title: 'Faster to market',
      body:
        'AI monitoring surfaces regulatory shifts, infrastructure plans, and local market signals across emerging markets before they become consensus.'
    },
    {
      kicker: 'Analysis',
      title: 'Faster to analyse',
      body:
        'Valuation logic, comparables, demographic inputs, and risk modelling are assembled into one decision-ready view instead of separate consultant workstreams.'
    },
    {
      kicker: 'Decision',
      title: 'Faster to decide',
      body:
        'Structured memos compress weeks of fragmented diligence into a single briefing calibrated for institutional investors and family offices.'
    },
    {
      kicker: 'Finance',
      title: 'Faster to finance',
      body:
        'Bank-ready documentation and regional relationships shorten the path from identified asset to an executable financing structure.'
    },
    {
      kicker: 'Execution',
      title: 'Faster to execute',
      body:
        'Legal, regulatory, and delivery coordination stay under one operating surface so the deal moves from signal to settlement without handoff drag.'
    }
  ];

  const marketRegions = [
    {
      name: 'Central & Eastern Europe',
      count: '06',
      countries: [
        'Czech Republic',
        'Bulgaria',
        'Romania',
        'Poland',
        'Moldova',
        'Albania'
      ]
    },
    {
      name: 'Latin America & Caribbean',
      count: '06',
      countries: ['Honduras', 'Dominican Republic', 'Bolivia', 'Panama', 'Belize', 'Cuba']
    },
    {
      name: 'Global frontier',
      count: '02',
      countries: ['Vietnam', 'Morocco']
    }
  ];

  const founders = [
    {
      name: 'Matej Havlin',
      role: 'Co-Founder & Director',
      bio:
        'Cross-border operator focused on combining AI-led workflow design with on-the-ground real estate execution across Central Europe and Latin America.'
    },
    {
      name: 'Lukas Havel',
      role: 'Co-Founder & Director',
      bio:
        'Thirty-year dealmaking background spanning sourcing, financing, and development strategy in markets where local nuance determines whether capital performs.'
    }
  ];

  const processSteps = [
    {
      title: 'Market intelligence',
      body:
        'Continuous monitoring of infrastructure, regulation, and transaction activity creates a live map of where pricing may move next.'
    },
    {
      title: 'Opportunity screening',
      body:
        'Assets are filtered against geography, ticket size, yield expectation, and risk appetite before human time is spent on the wrong pipeline.'
    },
    {
      title: 'Due diligence',
      body:
        'Legal, financial, technical, and local-market diligence are coordinated in parallel to compress timelines without sacrificing decision quality.'
    },
    {
      title: 'Structuring & finance',
      body:
        'SPV planning, partner alignment, and lender coordination turn shortlisted assets into bankable, execution-ready opportunities.'
    },
    {
      title: 'Execution & oversight',
      body:
        'Delivery oversight continues beyond the transaction so investors have visibility through development, repositioning, or lease-up.'
    }
  ];

  const contactDetails = [
    {
      label: 'Registered office',
      value: '20 Wenlock Road, London N1 7GU, United Kingdom'
    },
    {
      label: 'Company',
      value: 'Perfect Mission Ltd, registered in England & Wales, No. 08651715'
    },
    {
      label: 'Email',
      value: 'info@perfectmission.co.uk',
      href: 'mailto:info@perfectmission.co.uk'
    }
  ];

  const jsonLd = JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'ProfessionalService',
    name: 'Perfect Mission Ltd',
    url: 'https://perfectmission.co.uk',
    email: 'info@perfectmission.co.uk',
    description:
      'AI-driven real estate development consultancy for institutional investors targeting emerging markets.',
    areaServed: ['CZ', 'BG', 'RO', 'PL', 'MD', 'AL', 'HN', 'DO', 'BO', 'PA', 'BZ', 'CU', 'VN', 'MA'],
    address: {
      '@type': 'PostalAddress',
      streetAddress: '20 Wenlock Road',
      addressLocality: 'London',
      postalCode: 'N1 7GU',
      addressCountry: 'GB'
    },
    serviceType: 'Real Estate Development Consultancy'
  });

  let menuOpen = false;

  const currentYear = new Date().getFullYear();

  function closeMenu() {
    menuOpen = false;
  }
</script>

<svelte:head>
  <title>Perfect Mission | AI-Driven Real Estate Consultancy</title>
  <meta
    name="description"
    content="Perfect Mission identifies and executes real estate opportunities across emerging markets with AI-powered analysis and three decades of founder expertise."
  />
  <link rel="canonical" href="https://perfectmission.co.uk/" />
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://perfectmission.co.uk/" />
  <meta property="og:site_name" content="Perfect Mission" />
  <meta property="og:title" content="Perfect Mission | AI-Driven Real Estate Consultancy" />
  <meta
    property="og:description"
    content="Faster to market, analyse, decide, finance, and execute across frontier real estate markets."
  />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Perfect Mission | AI-Driven Real Estate Consultancy" />
  <meta
    name="twitter:description"
    content="Emerging market real estate consultancy for investors who need speed, structure, and cross-border execution."
  />
  <script type="application/ld+json">
    {jsonLd}
  </script>
</svelte:head>

<svelte:window onkeydown={(event) => (event.key === 'Escape' ? closeMenu() : undefined)} />

<div class="page-shell">
  <header class="site-header">
    <div class="site-header__inner">
      <a class="brand" href="#top" aria-label="Perfect Mission homepage">
        Perfect <span class="brand__accent">Mission</span>
      </a>

      <button
        class="nav-toggle"
        type="button"
        aria-controls="site-nav"
        aria-expanded={menuOpen}
        aria-label={menuOpen ? 'Close navigation menu' : 'Open navigation menu'}
        onclick={() => (menuOpen = !menuOpen)}
      >
        <span class="nav-toggle__bars" aria-hidden="true"></span>
      </button>

      <nav id="site-nav" class:site-nav--open={menuOpen} class="site-nav" aria-label="Primary">
        {#each navLinks as link}
          <a href={link.href} onclick={closeMenu}>{link.label}</a>
        {/each}
        <a href="#contact" class="site-nav__cta" onclick={closeMenu}>Get in touch</a>
      </nav>
    </div>

    <button
      type="button"
      class:menu-scrim--visible={menuOpen}
      class="menu-scrim"
      aria-label="Close navigation menu"
      onclick={closeMenu}
    ></button>
  </header>

  <main id="top">
    <section class="section section--dark hero" aria-labelledby="hero-title">
      <div class="section__inner hero__content">
        <div class="hero__copy">
          <span class="eyebrow eyebrow--dark">AI-driven real estate consultancy</span>
          <h1 id="hero-title" class="hero__title">
            Emerging market opportunities, <em>found fast</em>.
          </h1>
          <p class="hero__lede">
            Perfect Mission combines thirty years of founder expertise with AI-powered analysis to
            identify, evaluate, finance, and execute real estate investments across frontier
            markets before the rest of the market catches up.
          </p>
          <div class="cta-row">
            <a class="btn btn--primary" href="#contact">Request a briefing</a>
            <a class="btn btn--secondary" href="#approach">See the operating model</a>
          </div>
        </div>

        <div class="hero__stats" aria-label="Key highlights">
          {#each statHighlights as stat}
            <article class="stat-card">
              <span class="stat-card__value">{stat.value}</span>
              <span class="stat-card__label">{stat.label}</span>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="approach" class="section section--light" aria-labelledby="approach-title">
      <div class="section__inner">
        <div class="section__header section__header--centered">
          <span class="eyebrow eyebrow--light">Our approach</span>
          <h2 id="approach-title" class="section-title">Speed is the strategy</h2>
          <p class="section-copy">
            In emerging markets, the best opportunities disappear in days, not quarters. The
            operating model is designed to compress every stage without reducing diligence.
          </p>
        </div>

        <div class="grid grid--three">
          {#each approachPillars as pillar}
            <article class="card card--light">
              <span class="card__kicker">{pillar.kicker}</span>
              <h3 class="card__title">{pillar.title}</h3>
              <p class="card__body">{pillar.body}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="markets" class="section section--dark" aria-labelledby="markets-title">
      <div class="section__inner">
        <div class="section__header">
          <span class="eyebrow eyebrow--dark">Markets</span>
          <h2 id="markets-title" class="section-title">Focused where institutional capital is still early</h2>
          <p class="section-copy hero__lede">
            The coverage spans Central and Eastern Europe, Latin America, and select frontier
            markets where local speed and pattern recognition create an unfair advantage.
          </p>
        </div>

        <div class="markets-grid">
          {#each marketRegions as region}
            <article class="card card--dark market-region">
              <div class="market-region__heading">
                <h3>{region.name}</h3>
                <span class="market-region__count">{region.count} markets</span>
              </div>
              <div class="market-tags">
                {#each region.countries as country}
                  <span class="market-tag">{country}</span>
                {/each}
              </div>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="founders" class="section section--light" aria-labelledby="founders-title">
      <div class="section__inner">
        <div class="section__header section__header--centered">
          <span class="eyebrow eyebrow--light">Leadership</span>
          <h2 id="founders-title" class="section-title">Three decades of cross-border dealmaking</h2>
          <p class="section-copy">
            The technology speeds up execution. The judgement comes from operators who understand
            how real estate actually moves on the ground.
          </p>
        </div>

        <div class="grid grid--two">
          {#each founders as founder}
            <article class="card card--light">
              <span class="card__kicker">Founder</span>
              <h3 class="card__title">{founder.name}</h3>
              <p class="founder-card__meta">{founder.role}</p>
              <p class="founder-card__bio">{founder.bio}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="process" class="section section--dark" aria-labelledby="process-title">
      <div class="section__inner">
        <div class="section__header">
          <span class="eyebrow eyebrow--dark">Process</span>
          <h2 id="process-title" class="section-title">From signal to settlement</h2>
          <p class="section-copy hero__lede">
            A five-stage pipeline turns fragmented market information into a bankable, executable
            opportunity set for investors who need speed without sloppy underwriting.
          </p>
        </div>

        <div class="grid grid--three process-grid">
          {#each processSteps as step}
            <article class="card card--dark process-card">
              <h3 class="card__title">{step.title}</h3>
              <p class="card__body">{step.body}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="contact" class="section section--surface" aria-labelledby="contact-title">
      <div class="section__inner">
        <div class="section__header section__header--centered">
          <span class="eyebrow eyebrow--muted">Contact</span>
          <h2 id="contact-title" class="section-title">Start with a market briefing</h2>
          <p class="section-copy">
            Share the geography, asset profile, and ticket size you are exploring. We will respond
            through the contact route you specify below.
          </p>
        </div>

        <div class="contact-layout">
          <article class="card card--light">
            <h3 class="card__title">Perfect Mission Ltd</h3>
            <div class="contact-list">
              {#each contactDetails as item}
                <div class="contact-item">
                  <span class="contact-item__label">{item.label}</span>
                  {#if item.href}
                    <p class="contact-item__value">
                      <a href={item.href}>{item.value}</a>
                    </p>
                  {:else}
                    <p class="contact-item__value">{item.value}</p>
                  {/if}
                </div>
              {/each}
            </div>
          </article>

          <article class="card card--light">
            <form
              class="contact-form"
              action="mailto:info@perfectmission.co.uk"
              method="POST"
              enctype="text/plain"
            >
              <div class="field-group">
                <label for="name">Name</label>
                <input id="name" name="name" type="text" autocomplete="name" required />
              </div>

              <div class="field-group">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" autocomplete="email" required />
              </div>

              <div class="field-group">
                <label for="company">Company or organisation</label>
                <input id="company" name="company" type="text" autocomplete="organization" />
              </div>

              <div class="field-group">
                <label for="message">Investment brief</label>
                <textarea
                  id="message"
                  name="message"
                  placeholder="Markets, ticket sizes, asset classes, or current sourcing constraints."
                ></textarea>
              </div>

              <button class="btn btn--primary btn--wide" type="submit">Send inquiry</button>
              <p class="contact-note">
                Prefer direct email? Use <a href="mailto:info@perfectmission.co.uk">info@perfectmission.co.uk</a>.
              </p>
            </form>
          </article>
        </div>
      </div>
    </section>

    <section class="section section--dark" aria-labelledby="cta-title">
      <div class="section__inner">
        <div class="section__header section__header--centered">
          <span class="eyebrow eyebrow--dark">Get started</span>
          <h2 id="cta-title" class="section-title">The best opportunities do not wait for committee speed</h2>
          <p class="section-copy hero__lede">
            Whether you are a family office, institutional investor, or development partner, the
            value is the same: better market intelligence, earlier access, and tighter execution.
          </p>
          <div class="cta-row cta-row--center">
            <a class="btn btn--primary" href="#contact">Request a market brief</a>
            <a class="btn btn--secondary" href="mailto:info@perfectmission.co.uk">Email directly</a>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="footer__inner">
      <span>Perfect Mission Ltd · Registered in England & Wales · Company No. 08651715</span>
      <span>© {currentYear} Perfect Mission Ltd. All rights reserved.</span>
    </div>
  </footer>
</div>
