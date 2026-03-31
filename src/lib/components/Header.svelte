<script lang="ts">
  import { browser } from '$app/environment';
  import { onMount, tick } from 'svelte';
  
  let { currentPath = '/' }: { currentPath?: string } = $props();
  let menuOpen = $state(false);
  let scrolled = $state(false);
  let darkMode = $state(true);
  let currentHash = $state('');
  let headerElement: HTMLElement | undefined;
  let menuButton: HTMLButtonElement | undefined;
  let navElement: HTMLElement | undefined;
  let lastFocusedElement: HTMLElement | null = null;
  let lastLocationKey = '';
  let backgroundElements: HTMLElement[] = [];
  let backgroundAriaHidden = new Map<HTMLElement, string | null>();
  let headerChromeElements: HTMLElement[] = [];
  let headerChromeAriaHidden = new Map<HTMLElement, string | null>();
  let headerChromeTabIndex = new Map<HTMLElement, string | null>();
  let headerResizeObserver: ResizeObserver | null = null;
  let sessionTheme: 'dark' | 'light' | null = null;

  const links = [
    { href: '/', label: 'Overview' },
    { href: '/markets/', label: 'Markets' },
    { href: '/#contact', label: 'Contact' }
  ];

  function readStoredTheme(): string | null {
    try {
      return localStorage.getItem('theme') ?? sessionTheme;
    } catch {
      return sessionTheme;
    }
  }

  function persistThemePreference(theme: 'dark' | 'light') {
    sessionTheme = theme;
    try {
      localStorage.setItem('theme', theme);
    } catch {
      // Ignore storage failures so the UI still updates for the current session.
    }
  }

  onMount(() => {
    // Check for saved theme preference
    const savedTheme = readStoredTheme();
    if (savedTheme) {
      darkMode = savedTheme === 'dark';
    } else {
      darkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
    applyTheme();
    
    const handleScroll = () => {
      scrolled = window.scrollY > 20;
    };
    const handleHashChange = () => {
      currentHash = window.location.hash;
    };
    const desktopMedia = window.matchMedia('(min-width: 901px)');
    const handleDesktopChange = (event: MediaQueryListEvent) => {
      if (event.matches) {
        closeMenu({ restoreFocus: false });
      }
    };

    updateHeaderHeightVariable();
    if ('ResizeObserver' in window) {
      headerResizeObserver = new ResizeObserver(() => {
        updateHeaderHeightVariable();
      });

      if (headerElement) {
        headerResizeObserver.observe(headerElement);
      }
    }
    
    window.addEventListener('scroll', handleScroll, { passive: true });
    window.addEventListener('hashchange', handleHashChange);
    desktopMedia.addEventListener('change', handleDesktopChange);
    handleScroll();
    handleHashChange();
    
    return () => {
      restoreBackgroundContent();
      headerResizeObserver?.disconnect();
      headerResizeObserver = null;
      window.removeEventListener('scroll', handleScroll);
      window.removeEventListener('hashchange', handleHashChange);
      desktopMedia.removeEventListener('change', handleDesktopChange);
      document.body.style.overflow = '';
    };
  });

  $effect(() => {
    if (!browser) {
      return;
    }

    const locationKey = `${currentPath}${currentHash}`;
    if (!lastLocationKey) {
      lastLocationKey = locationKey;
      return;
    }

    if (menuOpen && locationKey !== lastLocationKey) {
      closeMenu({ restoreFocus: false });
    }

    lastLocationKey = locationKey;
  });

  $effect(() => {
    if (!browser) {
      return;
    }

    if (!menuOpen) {
      restoreBackgroundContent();
      return;
    }

    disableBackgroundContent();

    return () => {
      restoreBackgroundContent();
    };
  });

  function toggleTheme() {
    darkMode = !darkMode;
    applyTheme();
    persistThemePreference(darkMode ? 'dark' : 'light');
    
    window.posthog?.capture('theme_toggle', {
      site: 'perfectmission.co.uk',
      theme: darkMode ? 'dark' : 'light'
    });
  }

  function applyTheme() {
    if (darkMode) {
      document.documentElement.removeAttribute('data-theme');
    } else {
      document.documentElement.setAttribute('data-theme', 'light');
    }
  }

  function updateHeaderHeightVariable() {
    if (!headerElement) {
      return;
    }

    headerElement.style.setProperty('--site-header-height', `${headerElement.offsetHeight}px`);
  }

  function isActive(href: string) {
    if (href.startsWith('mailto:')) {
      return false;
    }

    if (href.includes('#')) {
      const [path, hash] = href.split('#');
      const resolvedPath = path || '/';
      return currentPath === resolvedPath && currentHash === `#${hash}`;
    }

    if (href === '/') {
      return currentPath === '/' && currentHash === '';
    }

    return href === '/' ? currentPath === '/' : currentPath === href || currentPath.startsWith(`${href}`);
  }

  function getAriaCurrent(href: string) {
    if (!isActive(href)) {
      return undefined;
    }

    return href.includes('#') ? 'location' : 'page';
  }

  function trackNavigation(target: string, href: string) {
    window.posthog?.capture('navigation_click', {
      site: 'perfectmission.co.uk',
      pathname: currentPath,
      target,
      href
    });
  }

  function handleNavLinkClick(link: { href: string; label: string }) {
    trackNavigation(link.label.toLowerCase(), link.href);
    closeMenu({ restoreFocus: false });
  }

  async function toggleMenu() {
    if (menuOpen) {
      closeMenu();
      return;
    }

    lastFocusedElement = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    menuOpen = true;
    document.body.style.overflow = 'hidden';
    await tick();
    focusFirstMenuItem();
  }

  function getFocusableMenuElements() {
    if (!navElement) {
      return [];
    }

    return Array.from(
      navElement.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );
  }

  function focusFirstMenuItem() {
    if (!navElement) {
      menuButton?.focus();
      return;
    }

    const firstPrimaryLink = navElement.querySelector<HTMLElement>('a[href]');
    if (firstPrimaryLink) {
      firstPrimaryLink.focus();
      return;
    }

    const [firstItem] = getFocusableMenuElements();
    if (firstItem) {
      firstItem.focus();
      return;
    }

    menuButton?.focus();
  }

  function keepFocusInsideMenu() {
    if (!menuOpen) {
      return;
    }

    const activeElement = document.activeElement;
    if (activeElement instanceof HTMLElement && navElement?.contains(activeElement)) {
      return;
    }

    focusFirstMenuItem();
  }

  function disableBackgroundContent() {
    const pageShell = navElement?.closest<HTMLElement>('.page-shell');
    if (pageShell) {
      backgroundElements = Array.from(
        pageShell.querySelectorAll<HTMLElement>(':scope > main, :scope > footer')
      );

      backgroundAriaHidden.clear();

      for (const element of backgroundElements) {
        backgroundAriaHidden.set(element, element.getAttribute('aria-hidden'));
        element.inert = true;
        element.setAttribute('aria-hidden', 'true');
      }
    }

    const header = navElement?.closest<HTMLElement>('header');
    if (!header) {
      return;
    }

    headerChromeElements = Array.from(
      header.querySelectorAll<HTMLElement>('.skip-link, .brand, .theme-toggle, .menu-toggle')
    );

    headerChromeAriaHidden.clear();
    headerChromeTabIndex.clear();

    for (const element of headerChromeElements) {
      headerChromeAriaHidden.set(element, element.getAttribute('aria-hidden'));
      headerChromeTabIndex.set(element, element.getAttribute('tabindex'));
      element.inert = true;
      element.setAttribute('aria-hidden', 'true');

      if (
        element instanceof HTMLAnchorElement ||
        element instanceof HTMLButtonElement ||
        element.hasAttribute('tabindex')
      ) {
        element.setAttribute('tabindex', '-1');
      }
    }
  }

  function restoreBackgroundContent() {
    for (const element of backgroundElements) {
      element.inert = false;
      const previousAriaHidden = backgroundAriaHidden.get(element);

      if (previousAriaHidden === null || previousAriaHidden === undefined) {
        element.removeAttribute('aria-hidden');
      } else {
        element.setAttribute('aria-hidden', previousAriaHidden);
      }
    }

    for (const element of headerChromeElements) {
      element.inert = false;
      const previousAriaHidden = headerChromeAriaHidden.get(element);
      const previousTabIndex = headerChromeTabIndex.get(element);

      if (previousAriaHidden === null || previousAriaHidden === undefined) {
        element.removeAttribute('aria-hidden');
      } else {
        element.setAttribute('aria-hidden', previousAriaHidden);
      }

      if (previousTabIndex === null || previousTabIndex === undefined) {
        element.removeAttribute('tabindex');
      } else {
        element.setAttribute('tabindex', previousTabIndex);
      }
    }

    backgroundElements = [];
    backgroundAriaHidden.clear();
    headerChromeElements = [];
    headerChromeAriaHidden.clear();
    headerChromeTabIndex.clear();
  }

  async function restoreMenuFocus() {
    await tick();
    (lastFocusedElement ?? menuButton)?.focus();
    lastFocusedElement = null;
  }

  function closeMenu({ restoreFocus = true }: { restoreFocus?: boolean } = {}) {
    menuOpen = false;
    document.body.style.overflow = '';
    if (restoreFocus) {
      void restoreMenuFocus();
    } else {
      lastFocusedElement = null;
    }
  }

  function trapMenuFocus(event: KeyboardEvent) {
    const focusable = getFocusableMenuElements();
    if (focusable.length === 0) {
      event.preventDefault();
      menuButton?.focus();
      return;
    }

    const firstItem = focusable[0];
    const lastItem = focusable[focusable.length - 1];
    const activeElement = document.activeElement;
    const focusInsideMenu =
      activeElement instanceof HTMLElement ? focusable.includes(activeElement) : false;

    if (!focusInsideMenu) {
      event.preventDefault();
      (event.shiftKey ? lastItem : firstItem).focus();
      return;
    }

    if (event.shiftKey && activeElement === firstItem) {
      event.preventDefault();
      lastItem.focus();
    } else if (!event.shiftKey && activeElement === lastItem) {
      event.preventDefault();
      firstItem.focus();
    }
  }

  function handleWindowKeydown(event: KeyboardEvent) {
    if (!menuOpen) {
      return;
    }

    if (event.key === 'Escape') {
      closeMenu();
    } else if (event.key === 'Tab') {
      trapMenuFocus(event);
    }
  }

  function handleWindowFocusIn(event: FocusEvent) {
    if (!menuOpen) {
      return;
    }

    const target = event.target;
    if (target instanceof HTMLElement && navElement?.contains(target)) {
      return;
    }

    keepFocusInsideMenu();
  }
</script>

<svelte:window onkeydown={handleWindowKeydown} onfocusin={handleWindowFocusIn} />

<header bind:this={headerElement} class="site-header" class:site-header--scrolled={scrolled}>
  <a class="skip-link" href="#main-content">Skip to main content</a>
  <div class="container site-header__inner">
    <a class="brand" href="/" onclick={() => trackNavigation('home', '/') }>
      Perfect<span>Mission</span>
    </a>

    <div class="header-actions">
      <!-- Theme Toggle -->
      <button
        type="button"
        class="theme-toggle"
        onclick={toggleTheme}
        aria-label={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
        title={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
      >
        {#if darkMode}
          <!-- Sun icon -->
          <svg
            width="18"
            height="18"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
            focusable="false"
          >
            <circle cx="12" cy="12" r="5"/>
            <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>
          </svg>
        {:else}
          <!-- Moon icon -->
          <svg
            width="18"
            height="18"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
            focusable="false"
          >
            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
          </svg>
        {/if}
      </button>

      <button
        type="button"
        class="menu-toggle"
        bind:this={menuButton}
        aria-expanded={menuOpen}
        aria-controls="primary-navigation"
        aria-label={menuOpen ? 'Close primary navigation menu' : 'Open primary navigation menu'}
        onclick={toggleMenu}
      >
        <span></span>
        <span></span>
        <span></span>
      </button>
    </div>

    <nav
      id="primary-navigation"
      bind:this={navElement}
      class:site-nav--open={menuOpen}
      class="site-nav"
      aria-label="Primary navigation"
    >
      {#each links as link}
        <a
          href={link.href}
          class:active={isActive(link.href)}
          aria-current={getAriaCurrent(link.href)}
          onclick={() => void handleNavLinkClick(link)}
        >
          {link.label}
        </a>
      {/each}
      {#if menuOpen}
        <button
          type="button"
          class="site-nav__close"
          aria-label="Close primary navigation menu"
          onclick={() => closeMenu()}
        >
          Close navigation
        </button>
      {/if}
    </nav>
  </div>
</header>

<!-- Overlay for mobile menu -->
{#if menuOpen}
  <button
    type="button"
    class="mobile-menu-overlay"
    onclick={() => closeMenu()}
    aria-label="Close menu"
    tabindex="-1"
  ></button>
{/if}

<style>
  .header-actions {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-left: auto;
  }

  .theme-toggle {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2.5rem;
    height: 2.5rem;
    padding: 0;
    border: 1px solid var(--color-line-strong);
    border-radius: var(--radius-md);
    background: rgba(255, 255, 255, 0.03);
    color: var(--color-text-secondary);
    cursor: pointer;
    transition: all var(--transition-base);
  }

  .theme-toggle:hover {
    border-color: var(--color-accent);
    color: var(--color-accent);
    background: var(--color-accent-subtle);
  }

  .mobile-menu-overlay {
    position: fixed;
    inset: 0;
    display: block;
    width: 100%;
    border: 0;
    padding: 0;
    background: rgba(10, 22, 40, 0.8);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    z-index: 90;
    animation: fadeIn 0.25s ease;
    cursor: pointer;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  
  @media (min-width: 901px) {
    .mobile-menu-overlay {
      display: none;
    }
    
    .theme-toggle {
      margin-right: 0.5rem;
    }
  }

  @media (max-width: 640px) {
    .theme-toggle {
      width: 2.25rem;
      height: 2.25rem;
    }
    
    .theme-toggle svg {
      width: 16px;
      height: 16px;
    }
  }
</style>
