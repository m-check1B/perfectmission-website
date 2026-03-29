<script lang="ts">
  let { currentPath = '/' }: { currentPath?: string } = $props();

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
</script>

<header class="site-header">
  <div class="container site-header__inner">
    <a class="brand" href="/">
      Perfect<span>Mission</span>
    </a>

    <nav class="site-nav" aria-label="Primary">
      {#each links as link}
        <a
          href={link.href}
          class:active={isActive(link.href)}
          onclick={() => trackNavigation(link.label.toLowerCase(), link.href)}
        >
          {link.label}
        </a>
      {/each}
    </nav>
  </div>
</header>
