<script lang="ts">
  import { browser } from '$app/environment';
  import { afterNavigate } from '$app/navigation';
  import { onMount } from 'svelte';
  import '@fontsource/inter/latin-400.css';
  import '@fontsource/inter/latin-600.css';
  import '@fontsource/inter/latin-700.css';
  import '@fontsource/jetbrains-mono/latin-400.css';
  import '@fontsource/jetbrains-mono/latin-600.css';
  import '@fontsource/playfair-display/latin-700.css';
  import '@fontsource/playfair-display/latin-700-italic.css';
  import inter400Woff2 from '@fontsource/inter/files/inter-latin-400-normal.woff2';
  import playfair700Woff2 from '@fontsource/playfair-display/files/playfair-display-latin-700-normal.woff2';
  import playfair700ItalicWoff2 from '@fontsource/playfair-display/files/playfair-display-latin-700-italic.woff2';
  import CookieConsent from '$lib/components/CookieConsent.svelte';
  import { hasConsent, initPostHog } from '$lib/posthog';
  import '../app.css';

  let { children } = $props();

  function focusHashTarget(hash = window.location.hash) {
    if (!hash) {
      return;
    }

    const targetId = decodeURIComponent(hash.slice(1));
    const target = document.getElementById(targetId);
    if (!target) {
      return;
    }

    requestAnimationFrame(() => {
      target.focus({ preventScroll: true });
    });
  }

  if (browser && hasConsent()) {
    void initPostHog('perfectmission.co.uk');
  }

  onMount(() => {
    const handleHashChange = () => {
      focusHashTarget();
    };

    const handleDocumentClick = (event: MouseEvent) => {
      const trigger = event.target;
      if (!(trigger instanceof Element)) {
        return;
      }

      const link = trigger.closest<HTMLAnchorElement>('a[href*="#"]');
      if (!link || link.origin !== window.location.origin || link.pathname !== window.location.pathname) {
        return;
      }

      if (link.hash && link.hash === window.location.hash) {
        focusHashTarget(link.hash);
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    document.addEventListener('click', handleDocumentClick);

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
      document.removeEventListener('click', handleDocumentClick);
    };
  });

  afterNavigate(() => {
    focusHashTarget();
  });
</script>

<svelte:head>
  <link
    rel="preload"
    href={inter400Woff2}
    as="font"
    type="font/woff2"
    crossorigin="anonymous"
  />
  <link
    rel="preload"
    href={playfair700Woff2}
    as="font"
    type="font/woff2"
    crossorigin="anonymous"
  />
  <link
    rel="preload"
    href={playfair700ItalicWoff2}
    as="font"
    type="font/woff2"
    crossorigin="anonymous"
  />
</svelte:head>

<CookieConsent site="perfectmission.co.uk" />
{@render children?.()}
