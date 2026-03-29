<script lang="ts">
  import { browser } from '$app/environment';
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

  if (browser && hasConsent()) {
    initPostHog('perfectmission.co.uk');
  }
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
