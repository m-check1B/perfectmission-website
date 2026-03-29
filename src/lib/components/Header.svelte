<script lang="ts">
  import { onMount } from 'svelte';
  
  let { currentPath = '/' }: { currentPath?: string } = $props();
  let menuOpen = $state(false);
  let scrolled = $state(false);
  let darkMode = $state(true);

  const links = [
    { href: '/', label: 'Overview' },
    { href: '/markets/', label: 'Markets' },
    { href: '/#contact', label: 'Contact' }
  ];

  onMount(() => {
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      darkMode = savedTheme === 'dark';
    } else {
      darkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
    applyTheme();
    
    const handleScroll = () => {
      scrolled = window.scrollY > 20;
    };
    
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();
    
    return () => window.removeEventListener('scroll', handleScroll);
  });

  function toggleTheme() {
    darkMode = !darkMode;
    applyTheme();
    localStorage.setItem('theme', darkMode ? 'dark' : 'light');
    
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

  function isActive(href: string) {
    if (href.startsWith('mailto:') || href.includes('#')) {
      return false;
    }
    return href === '/' ? currentPath === '/' : currentPath === href || currentPath.startsWith(`${href}`);
  }

  function trackNavigation(target: string, href: string) {
    window.posthog?.capture('navigation_click', {
      site: 'perfectmission.co.uk',
      pathname: currentPath,
      target,
      href
    });
  }

  function toggleMenu() {
    menuOpen = !menuOpen;
    if (menuOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
  }

  function closeMenu() {
    menuOpen = false;
    document.body.style.overflow = '';
  }

  function handleWindowKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      closeMenu();
    }
  }
</script>

<svelte:window onkeydown={handleWindowKeydown} />

<header class="site-header" class:site-header--scrolled={scrolled}>
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
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="5"/>
            <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>
          </svg>
        {:else}
          <!-- Moon icon -->
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
          </svg>
        {/if}
      </button>

      <button
        type="button"
        class="menu-toggle"
        aria-expanded={menuOpen}
        aria-controls="primary-navigation"
        aria-label={menuOpen ? 'Close navigation menu' : 'Open navigation menu'}
        onclick={toggleMenu}
      >
        <span></span>
        <span></span>
        <span></span>
      </button>
    </div>

    <nav
      id="primary-navigation"
      class:site-nav--open={menuOpen}
      class="site-nav"
      aria-label="Primary"
    >
      {#each links as link}
        <a
          href={link.href}
          class:active={isActive(link.href)}
          onclick={() => {
            trackNavigation(link.label.toLowerCase(), link.href);
            closeMenu();
          }}
        >
          {link.label}
        </a>
      {/each}
    </nav>
  </div>
</header>

<!-- Overlay for mobile menu -->
{#if menuOpen}
  <div 
    class="mobile-menu-overlay" 
    onclick={closeMenu}
    onkeydown={(e) => e.key === 'Enter' && closeMenu()}
    role="button"
    tabindex="0"
    aria-label="Close menu"
  ></div>
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
    background: rgba(10, 22, 40, 0.8);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    z-index: 90;
    animation: fadeIn 0.25s ease;
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
