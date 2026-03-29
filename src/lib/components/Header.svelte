<script lang="ts">
  let { currentPath = '/' }: { currentPath?: string } = $props();
  let menuOpen = $state(false);

  const links = [
    { href: '/', label: 'Overview' },
    { href: '/markets/', label: 'Markets' },
    { href: '/#contact', label: 'Contact' }
  ];

  function isActive(href: string) {
    if (href.startsWith('mailto:') || href.includes('#')) {
      return false;
    }

    return href === '/'
      ? currentPath === '/'
      : currentPath === href || currentPath.startsWith(`${href}`);
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
  }

  function closeMenu() {
    menuOpen = false;
  }

  function handleWindowKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      closeMenu();
    }
  }
</script>

<svelte:window onkeydown={handleWindowKeydown} />

<header class="site-header">
  <div class="container site-header__inner">
    <a class="brand" href="/">
      Perfect<span>Mission</span>
    </a>

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
