<script lang="ts">
  import { onMount, tick } from 'svelte';
  import { reveal } from '$lib/actions/reveal';

  const navLinks = [
    { href: '#approach', label: 'Approach' },
    { href: '#markets', label: 'Markets' },
    { href: '#founders', label: 'Founders' },
    { href: '#process', label: 'Process' }
  ];
  const contactSectionHref = '#contact';
  const trackedSectionHrefs = [...navLinks.map((link) => link.href), contactSectionHref];
  const sectionHeadingIds = {
    '#approach': 'approach-title',
    '#markets': 'markets-title',
    '#founders': 'founders-title',
    '#process': 'process-title',
    '#contact': 'contact-title'
  } as const;

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

  const coverageSignals = [
    {
      label: 'CEE',
      body: 'Institutional screening from Prague and Sofia through Bucharest, Warsaw, Chisinau, and Tirana.'
    },
    {
      label: 'LATAM',
      body: 'Deal-flow coverage across Honduras, Dominican Republic, Bolivia, Panama, Belize, and Cuba.'
    },
    {
      label: 'Global',
      body: 'Frontier market visibility in Vietnam and Morocco for investors expanding beyond crowded hubs.'
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

  const siteUrl = 'https://perfectmission.co.uk';
  const contactEmail = 'info@perfectmission.co.uk';
  const heroImageUrl = '/images/market-atlas-panel.svg';
  const socialImageUrl = `${siteUrl}/social/perfect-mission-og.png`;
  const mobileNavBreakpoint = 768;
  const mobileMenuFocusableSelector =
    'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])';
  const contactFieldOrder = ['name', 'email', 'message'] as const;
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  type ContactField = (typeof contactFieldOrder)[number];
  type ContactErrors = Partial<Record<ContactField, string>>;
  type ContactTouched = Partial<Record<ContactField, boolean>>;

  const jsonLd = JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'ProfessionalService',
    name: 'Perfect Mission Ltd',
    url: siteUrl,
    email: contactEmail,
    description:
      'AI-driven real estate development consultancy for institutional investors targeting emerging markets.',
    image: socialImageUrl,
    areaServed: ['CZ', 'BG', 'RO', 'PL', 'MD', 'AL', 'HN', 'DO', 'BO', 'PA', 'BZ', 'CU', 'VN', 'MA'],
    founder: founders.map((founder) => ({
      '@type': 'Person',
      name: founder.name
    })),
    address: {
      '@type': 'PostalAddress',
      streetAddress: '20 Wenlock Road',
      addressLocality: 'London',
      postalCode: 'N1 7GU',
      addressCountry: 'GB'
    },
    serviceType: 'Real Estate Development Consultancy'
  }).replace(/</g, '\\u003c');

  let menuOpen = false;
  let headerCondensed = false;
  let activeNavHref = '';
  let navElement: HTMLElement | undefined;
  let navToggleElement: HTMLButtonElement | undefined;
  let contactName = '';
  let contactEmailAddress = '';
  let contactCompany = '';
  let contactMessage = '';
  let contactErrors: ContactErrors = {};
  let contactTouched: ContactTouched = {};
  let contactFormSubmitted = false;
  let contactFormEnhanced = false;

  const currentYear = new Date().getFullYear();

  async function openMenu() {
    menuOpen = true;
    await tick();
    navElement?.querySelector<HTMLAnchorElement>('a')?.focus();
  }

  async function closeMenu(restoreFocus = false) {
    menuOpen = false;

    if (!restoreFocus) {
      return;
    }

    await tick();
    navToggleElement?.focus();
  }

  function toggleMenu() {
    if (menuOpen) {
      void closeMenu(true);
      return;
    }

    void openMenu();
  }

  function syncMenuLock(isOpen: boolean) {
    if (typeof document === 'undefined') {
      return;
    }

    document.documentElement.classList.toggle('menu-open', isOpen);
    document.body.classList.toggle('menu-open', isOpen);
  }

  function getMenuFocusables() {
    const navFocusables = Array.from(
      navElement?.querySelectorAll<HTMLElement>(mobileMenuFocusableSelector) ?? []
    );
    const toggleFocusable = navToggleElement ? [navToggleElement] : [];

    return [...toggleFocusable, ...navFocusables].filter(
      (element) =>
        !element.hasAttribute('disabled') &&
        element.getAttribute('aria-hidden') !== 'true' &&
        element.getClientRects().length > 0
    );
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape' && menuOpen) {
      void closeMenu(true);
      return;
    }

    if (event.key !== 'Tab' || !menuOpen) {
      return;
    }

    const focusables = getMenuFocusables();

    if (focusables.length === 0) {
      return;
    }

    const firstFocusable = focusables[0];
    const lastFocusable = focusables[focusables.length - 1];
    const activeElement = document.activeElement as HTMLElement | null;

    if (!activeElement || !focusables.includes(activeElement)) {
      event.preventDefault();
      (event.shiftKey ? lastFocusable : firstFocusable).focus();
      return;
    }

    if (event.shiftKey && activeElement === firstFocusable) {
      event.preventDefault();
      lastFocusable.focus();
      return;
    }

    if (!event.shiftKey && activeElement === lastFocusable) {
      event.preventDefault();
      firstFocusable.focus();
    }
  }

  function handleScroll() {
    if (typeof window === 'undefined') {
      return;
    }

    headerCondensed = window.scrollY > 24;
    updateActiveNav();
  }

  function handleResize() {
    if (typeof window === 'undefined') {
      return;
    }

    if (window.innerWidth > mobileNavBreakpoint && menuOpen) {
      void closeMenu();
    }

    updateActiveNav();
  }

  function updateActiveNav() {
    if (typeof document === 'undefined' || typeof window === 'undefined') {
      return;
    }

    const threshold = Math.max(window.innerHeight * 0.32, 96);
    activeNavHref =
      trackedSectionHrefs.find((href) => {
        const section = document.querySelector<HTMLElement>(href);

        if (!section) {
          return false;
        }

        const bounds = section.getBoundingClientRect();
        return bounds.top <= threshold && bounds.bottom >= threshold;
      }) ?? '';
  }

  function getSectionNavigationTarget(href: string) {
    if (typeof document === 'undefined') {
      return null;
    }

    const section = document.querySelector<HTMLElement>(href);

    if (!section) {
      return null;
    }

    const headingId = sectionHeadingIds[href as keyof typeof sectionHeadingIds];
    const focusTarget = headingId ? document.getElementById(headingId) : section;

    if (!(focusTarget instanceof HTMLElement)) {
      return null;
    }

    return { section, focusTarget };
  }

  function updateSectionHash(href: string) {
    if (typeof window === 'undefined') {
      return;
    }

    const { history, location } = window;
    const historyMethod = location.hash === href ? 'replaceState' : 'pushState';
    history[historyMethod](history.state, '', href);
  }

  async function focusSectionHeading(href: string) {
    if (typeof window === 'undefined') {
      return;
    }

    const target = getSectionNavigationTarget(href);

    if (!target) {
      return;
    }

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    target.section.scrollIntoView({
      block: 'start',
      behavior: prefersReducedMotion ? 'auto' : 'smooth'
    });
    updateSectionHash(href);
    await tick();
    target.focusTarget.focus({ preventScroll: true });
    activeNavHref = href;
  }

  async function focusPageTop() {
    if (typeof document === 'undefined' || typeof window === 'undefined') {
      return;
    }

    const mainContent = document.getElementById('main-content');
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const { history, location } = window;
    const historyMethod = location.hash === '#top' ? 'replaceState' : 'pushState';

    window.scrollTo({
      top: 0,
      behavior: prefersReducedMotion ? 'auto' : 'smooth'
    });
    history[historyMethod](history.state, '', '#top');
    await tick();
    mainContent?.focus({ preventScroll: true });
    activeNavHref = '';
  }

  async function handleSectionNavigation(event: MouseEvent, href: string) {
    if (
      event.defaultPrevented ||
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return;
    }

    const target = getSectionNavigationTarget(href);

    if (!target) {
      await closeMenu();
      return;
    }

    event.preventDefault();
    await closeMenu();
    await tick();
    await focusSectionHeading(href);
  }

  async function handleTopNavigation(event: MouseEvent) {
    if (
      event.defaultPrevented ||
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return;
    }

    event.preventDefault();

    if (menuOpen) {
      await closeMenu();
      await tick();
    }

    await focusPageTop();
  }

  function getContactFieldValue(field: ContactField) {
    switch (field) {
      case 'name':
        return contactName.trim();
      case 'email':
        return contactEmailAddress.trim();
      case 'message':
        return contactMessage.trim();
    }
  }

  function validateContactField(field: ContactField) {
    const value = getContactFieldValue(field);

    if (field === 'name' && !value) {
      return 'Enter your name so we know who to reply to.';
    }

    if (field === 'email') {
      if (!value) {
        return 'Enter an email address for the reply.';
      }

      if (!emailPattern.test(value)) {
        return 'Enter a valid email address.';
      }
    }

    if (field === 'message' && !value) {
      return 'Add a short investment brief so the outreach is actionable.';
    }

    return '';
  }

  function getContactDescribedBy(field: ContactField, hintId: string) {
    return getDisplayedContactError(field) ? `${hintId} ${field}-error` : hintId;
  }

  function shouldShowContactError(field: ContactField) {
    return contactFormSubmitted || Boolean(contactTouched[field]);
  }

  function getDisplayedContactError(field: ContactField) {
    return shouldShowContactError(field) ? contactErrors[field] : undefined;
  }

  function setContactError(field: ContactField) {
    const nextError = validateContactField(field);
    const nextErrors = { ...contactErrors };

    if (nextError) {
      nextErrors[field] = nextError;
    } else {
      delete nextErrors[field];
    }

    contactErrors = nextErrors;
  }

  function handleContactBlur(field: ContactField) {
    contactTouched = { ...contactTouched, [field]: true };
    setContactError(field);
  }

  function handleContactInput(field: ContactField) {
    if (!shouldShowContactError(field)) {
      return;
    }

    setContactError(field);
  }

  function handleContactSubmit(event: SubmitEvent) {
    event.preventDefault();
    contactFormSubmitted = true;
    contactTouched = contactFieldOrder.reduce<ContactTouched>((touched, field) => {
      touched[field] = true;
      return touched;
    }, {});

    const nextErrors = contactFieldOrder.reduce<ContactErrors>((errors, field) => {
      const error = validateContactField(field);

      if (error) {
        errors[field] = error;
      }

      return errors;
    }, {});

    contactErrors = nextErrors;

    const firstInvalidField = contactFieldOrder.find((field) => nextErrors[field]);

    if (firstInvalidField) {
      document.getElementById(firstInvalidField)?.focus();
      return;
    }

    const subjectParts = ['Perfect Mission market briefing'];

    if (contactCompany.trim()) {
      subjectParts.push(contactCompany.trim());
    } else if (contactName.trim()) {
      subjectParts.push(contactName.trim());
    }

    const bodyLines = [
      `Name: ${contactName.trim() || 'Not provided'}`,
      `Email: ${contactEmailAddress.trim() || 'Not provided'}`,
      `Company: ${contactCompany.trim() || 'Not provided'}`,
      '',
      'Investment brief:',
      contactMessage.trim() || 'Not provided'
    ];

    const mailtoHref = `mailto:${contactEmail}?subject=${encodeURIComponent(subjectParts.join(' - '))}&body=${encodeURIComponent(bodyLines.join('\n'))}`;

    window.location.href = mailtoHref;
  }

  onMount(() => {
    contactFormEnhanced = true;
    handleScroll();
    handleResize();
    syncMenuLock(menuOpen);

    return () => {
      syncMenuLock(false);
    };
  });

  $: syncMenuLock(menuOpen);
</script>

<svelte:head>
  <title>Perfect Mission | AI-Driven Real Estate Consultancy</title>
  <meta
    name="description"
    content="Perfect Mission identifies and executes real estate opportunities across emerging markets with AI-powered analysis and three decades of founder expertise."
  />
  <meta name="theme-color" content="#0A1628" />
  <link rel="canonical" href={`${siteUrl}/`} />
  <link rel="preload" as="image" href={heroImageUrl} type="image/svg+xml" />
  <meta property="og:type" content="website" />
  <meta property="og:url" content={`${siteUrl}/`} />
  <meta property="og:site_name" content="Perfect Mission" />
  <meta property="og:title" content="Perfect Mission | AI-Driven Real Estate Consultancy" />
  <meta
    property="og:description"
    content="Faster to market, analyse, decide, finance, and execute across frontier real estate markets."
  />
  <meta property="og:image" content={socialImageUrl} />
  <meta property="og:image:alt" content="Perfect Mission social card with a stylized market atlas in navy and gold." />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:image:type" content="image/png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Perfect Mission | AI-Driven Real Estate Consultancy" />
  <meta
    name="twitter:description"
    content="Emerging market real estate consultancy for investors who need speed, structure, and cross-border execution."
  />
  <meta name="twitter:image" content={socialImageUrl} />
  <meta name="twitter:image:alt" content="Perfect Mission social card with a stylized market atlas in navy and gold." />
  {@html `<script type="application/ld+json">${jsonLd}</script>`}
</svelte:head>

<svelte:window onkeydown={handleKeydown} onscroll={handleScroll} onresize={handleResize} />

<div class="page-shell" id="top">
  <a class="skip-link" href="#main-content">Skip to content</a>

  <header class:site-header--condensed={headerCondensed} class="site-header">
    <div class="site-header__inner">
      <a
        class="brand"
        href="#top"
        aria-label="Perfect Mission homepage"
        onclick={(event) => void handleTopNavigation(event)}
      >
        Perfect <span class="brand__accent">Mission</span>
      </a>

      <button
        bind:this={navToggleElement}
        class="nav-toggle"
        type="button"
        aria-controls="site-nav"
        aria-expanded={menuOpen}
        aria-label={menuOpen ? 'Close navigation menu' : 'Open navigation menu'}
        onclick={toggleMenu}
      >
        <span class="nav-toggle__bars" aria-hidden="true"></span>
      </button>

      <nav
        bind:this={navElement}
        id="site-nav"
        class:site-nav--open={menuOpen}
        class="site-nav"
        aria-label="Primary"
      >
        {#each navLinks as link}
          <a
            href={link.href}
            aria-current={activeNavHref === link.href ? 'location' : undefined}
            onclick={(event) => void handleSectionNavigation(event, link.href)}
          >
            {link.label}
          </a>
        {/each}
        <a
          href={contactSectionHref}
          class="site-nav__cta"
          aria-current={activeNavHref === contactSectionHref ? 'location' : undefined}
          onclick={(event) => void handleSectionNavigation(event, contactSectionHref)}
        >
          Get in touch
        </a>
      </nav>
    </div>

    <button
      type="button"
      class:menu-scrim--visible={menuOpen}
      class="menu-scrim"
      aria-label="Close navigation menu"
      aria-hidden={menuOpen ? 'false' : 'true'}
      tabindex={menuOpen ? 0 : -1}
      onclick={() => void closeMenu(true)}
    ></button>
  </header>

  <main
    id="main-content"
    tabindex="-1"
    inert={menuOpen ? true : undefined}
    aria-hidden={menuOpen ? 'true' : undefined}
  >
    <section class="section section--dark hero" aria-labelledby="hero-title">
      <div class="section__inner hero__content">
        <div class="hero__layout">
          <div class="hero__copy reveal" use:reveal>
            <span class="eyebrow eyebrow--dark">AI-driven real estate consultancy</span>
            <h1 id="hero-title" class="hero__title">
              Emerging market opportunities, <em>found fast</em>.
            </h1>
            <p class="hero__lede">
              Perfect Mission combines thirty years of founder expertise with AI-powered analysis
              to identify, evaluate, finance, and execute real estate investments across frontier
              markets before the rest of the market catches up.
            </p>
            <div class="cta-row">
              <a
                class="btn btn--primary"
                href="#contact"
                onclick={(event) => void handleSectionNavigation(event, '#contact')}
              >
                Request a briefing
              </a>
              <a
                class="btn btn--secondary"
                href="#approach"
                onclick={(event) => void handleSectionNavigation(event, '#approach')}
              >
                See the operating model
              </a>
            </div>
          </div>

          <div class="hero__visual reveal" use:reveal={{ delay: 120 }}>
            <div class="hero__visual-frame">
              <span class="hero__visual-badge">Live market footprint</span>
              <img
                src={heroImageUrl}
                alt="Stylized market atlas connecting Central and Eastern Europe, Latin America, Morocco, and Vietnam."
                width="960"
                height="720"
                fetchpriority="high"
                decoding="async"
              />
            </div>

            <div class="hero__visual-meta" role="list" aria-label="Coverage summary">
              {#each coverageSignals as signal}
                <article class="hero__visual-region" role="listitem">
                  <span class="hero__visual-region-label">{signal.label}</span>
                  <p class="hero__visual-region-copy">{signal.body}</p>
                </article>
              {/each}
            </div>
          </div>
        </div>

        <div class="hero__stats" role="list" aria-label="Key highlights">
          {#each statHighlights as stat, index}
            <article class="stat-card reveal" role="listitem" use:reveal={{ delay: index * 80 }}>
              <span class="stat-card__value">{stat.value}</span>
              <span class="stat-card__label">{stat.label}</span>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="approach" class="section section--dark" aria-labelledby="approach-title">
      <div class="section__inner">
        <div class="section__header section__header--centered reveal" use:reveal>
          <span class="eyebrow eyebrow--dark">Our approach</span>
          <h2 id="approach-title" class="section-title" tabindex="-1">Speed is the strategy</h2>
          <p class="section-copy">
            In emerging markets, the best opportunities disappear in days, not quarters. The
            operating model is designed to compress every stage without reducing diligence.
          </p>
        </div>

        <div class="grid grid--three">
          {#each approachPillars as pillar, index}
            <article class="card card--dark reveal" use:reveal={{ delay: index * 80 }}>
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
        <div class="section__header reveal" use:reveal>
          <span class="eyebrow eyebrow--dark">Markets</span>
          <h2 id="markets-title" class="section-title" tabindex="-1">
            Focused where institutional capital is still early
          </h2>
          <p class="section-copy hero__lede">
            The coverage spans Central and Eastern Europe, Latin America, and select frontier
            markets where local speed and pattern recognition create an unfair advantage.
          </p>
        </div>

        <div class="markets-grid">
          {#each marketRegions as region, index}
            <article class="card card--dark market-region reveal" use:reveal={{ delay: index * 80 }}>
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
        <div class="section__header section__header--centered reveal" use:reveal>
          <span class="eyebrow eyebrow--light">Leadership</span>
          <h2 id="founders-title" class="section-title" tabindex="-1">
            Three decades of cross-border dealmaking
          </h2>
          <p class="section-copy">
            The technology speeds up execution. The judgement comes from operators who understand
            how real estate actually moves on the ground.
          </p>
        </div>

        <div class="grid grid--two">
          {#each founders as founder, index}
            <article class="card card--light reveal" use:reveal={{ delay: index * 80 }}>
              <span class="card__kicker">Founder</span>
              <h3 class="card__title">{founder.name}</h3>
              <p class="founder-card__meta">{founder.role}</p>
              <p class="founder-card__bio">{founder.bio}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="process" class="section section--light" aria-labelledby="process-title">
      <div class="section__inner">
        <div class="section__header reveal" use:reveal>
          <span class="eyebrow eyebrow--light">Process</span>
          <h2 id="process-title" class="section-title" tabindex="-1">From signal to settlement</h2>
          <p class="section-copy">
            A five-stage pipeline turns fragmented market information into a bankable, executable
            opportunity set for investors who need speed without sloppy underwriting.
          </p>
        </div>

        <div class="grid grid--three process-grid">
          {#each processSteps as step, index}
            <article class="card card--light process-card reveal" use:reveal={{ delay: index * 80 }}>
              <h3 class="card__title">{step.title}</h3>
              <p class="card__body">{step.body}</p>
            </article>
          {/each}
        </div>
      </div>
    </section>

    <section id="contact" class="section section--light" aria-labelledby="contact-title">
      <div class="section__inner">
        <div class="section__header section__header--centered reveal" use:reveal>
          <span class="eyebrow eyebrow--muted">Contact</span>
          <h2 id="contact-title" class="section-title" tabindex="-1">Start with a market briefing</h2>
          <p class="section-copy">
            Share the geography, asset profile, and ticket size you are exploring. We will respond
            through the contact route you specify below.
          </p>
        </div>

        <div class="contact-layout">
          <article class="card card--light reveal" use:reveal>
            <h3 class="card__title">Perfect Mission Ltd</h3>
            <div class="contact-list">
              {#each contactDetails as item}
                <div class="contact-item">
                  <span class="contact-item__label">{item.label}</span>
                  {#if item.href}
                    <p class="contact-item__value">
                      <a class="text-link" href={item.href}>{item.value}</a>
                    </p>
                  {:else}
                    <p class="contact-item__value">{item.value}</p>
                  {/if}
                </div>
              {/each}
            </div>
          </article>

          <article class="card card--light reveal" use:reveal={{ delay: 80 }}>
            <form
              class="contact-form"
              action={`mailto:${contactEmail}`}
              method="GET"
              aria-describedby="contact-note"
              novalidate={contactFormEnhanced}
              onsubmit={handleContactSubmit}
            >
              <div class="field-group">
                <label for="name">Name</label>
                <p class="field-group__hint" id="name-hint">Who should we reply to?</p>
                <input
                  bind:value={contactName}
                  aria-describedby={getContactDescribedBy('name', 'name-hint')}
                  aria-invalid={getDisplayedContactError('name') ? 'true' : undefined}
                  id="name"
                  name="name"
                  type="text"
                  autocomplete="name"
                  required
                  onblur={() => handleContactBlur('name')}
                  oninput={() => handleContactInput('name')}
                />
                {#if getDisplayedContactError('name')}
                  <p class="field-group__error" id="name-error" role="alert">
                    {getDisplayedContactError('name')}
                  </p>
                {/if}
              </div>

              <div class="field-group">
                <label for="email">Email</label>
                <p class="field-group__hint" id="email-hint">Used only to return the briefing.</p>
                <input
                  bind:value={contactEmailAddress}
                  aria-describedby={getContactDescribedBy('email', 'email-hint')}
                  aria-invalid={getDisplayedContactError('email') ? 'true' : undefined}
                  id="email"
                  name="email"
                  type="email"
                  autocomplete="email"
                  required
                  onblur={() => handleContactBlur('email')}
                  oninput={() => handleContactInput('email')}
                />
                {#if getDisplayedContactError('email')}
                  <p class="field-group__error" id="email-error" role="alert">
                    {getDisplayedContactError('email')}
                  </p>
                {/if}
              </div>

              <div class="field-group">
                <label for="company">Company or organisation</label>
                <p class="field-group__hint" id="company-hint">Optional, but useful for context.</p>
                <input
                  bind:value={contactCompany}
                  aria-describedby="company-hint"
                  id="company"
                  name="company"
                  type="text"
                  autocomplete="organization"
                />
              </div>

              <div class="field-group">
                <label for="message">Investment brief</label>
                <p class="field-group__hint" id="message-hint">
                  Include geography, asset type, ticket size, or current sourcing constraint.
                </p>
                <textarea
                  bind:value={contactMessage}
                  aria-describedby={getContactDescribedBy('message', 'message-hint')}
                  aria-invalid={getDisplayedContactError('message') ? 'true' : undefined}
                  id="message"
                  name="message"
                  placeholder="Markets, ticket sizes, asset classes, or current sourcing constraints."
                  required
                  onblur={() => handleContactBlur('message')}
                  oninput={() => handleContactInput('message')}
                ></textarea>
                {#if getDisplayedContactError('message')}
                  <p class="field-group__error" id="message-error" role="alert">
                    {getDisplayedContactError('message')}
                  </p>
                {/if}
              </div>

              <button class="btn btn--primary btn--wide" type="submit">Send inquiry</button>
              <p class="contact-note" id="contact-note">
                Submitting opens your email client with a prefilled brief. Prefer direct email? Use
                <a class="text-link" href={`mailto:${contactEmail}`}>{contactEmail}</a>.
              </p>
            </form>
          </article>
        </div>
      </div>
    </section>

    <section class="section section--dark" aria-labelledby="cta-title">
      <div class="section__inner">
        <div class="section__header section__header--centered reveal" use:reveal>
          <span class="eyebrow eyebrow--dark">Get started</span>
          <h2 id="cta-title" class="section-title">The best opportunities do not wait for committee speed</h2>
          <p class="section-copy hero__lede">
            Whether you are a family office, institutional investor, or development partner, the
            value is the same: better market intelligence, earlier access, and tighter execution.
          </p>
          <div class="cta-row cta-row--center">
            <a
              class="btn btn--primary"
              href="#contact"
              onclick={(event) => void handleSectionNavigation(event, '#contact')}
            >
              Request a market brief
            </a>
            <a class="btn btn--secondary" href="mailto:info@perfectmission.co.uk">Email directly</a>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer
    class="footer"
    inert={menuOpen ? true : undefined}
    aria-hidden={menuOpen ? 'true' : undefined}
  >
    <div class="footer__inner reveal" use:reveal>
      <span>Perfect Mission Ltd · Registered in England & Wales · Company No. 08651715</span>
      <span>© {currentYear} Perfect Mission Ltd. All rights reserved.</span>
    </div>
  </footer>
</div>
