<script lang="ts">
  import { browser } from '$app/environment';
  import { page } from '$app/state';
  import { onMount, tick } from 'svelte';
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
  import Footer from '$lib/components/Footer.svelte';
  import Header from '$lib/components/Header.svelte';
  import { hasConsent, initPostHog } from '$lib/posthog';
  import '../app.css';

  let { children } = $props();

  let restoreFocusedTarget: (() => void) | null = null;
  let hasHandledNavigation = false;
  let lastNavigationPath = '';
  let lastNavigationHash = '';
  const currentPath = $derived(
    page.url.pathname === '/' ? '/' : `${page.url.pathname.replace(/\/+$/, '')}/`
  );
  const currentHash = $derived(page.url.hash);

  function makeHashTargetTemporarilyFocusable(target: HTMLElement) {
    const hadTabIndex = target.hasAttribute('tabindex');
    const previousTabIndex = target.getAttribute('tabindex');

    if (!hadTabIndex) {
      target.setAttribute('tabindex', '-1');
    }

    let restored = false;
    const restore = () => {
      if (restored) {
        return;
      }

      restored = true;
      target.removeEventListener('blur', restore);

      if (!hadTabIndex) {
        target.removeAttribute('tabindex');
      } else if (previousTabIndex !== null) {
        target.setAttribute('tabindex', previousTabIndex);
      }
    };

    target.addEventListener('blur', restore, { once: true });
    return restore;
  }

  function getHashTarget(hash = window.location.hash) {
    if (!hash) {
      return null;
    }

    const targetId = decodeURIComponent(hash.slice(1));
    return document.getElementById(targetId);
  }

  function focusHashTarget(hash = window.location.hash) {
    const target = getHashTarget(hash);
    if (!target) {
      return;
    }

    requestAnimationFrame(() => {
      restoreFocusedTarget?.();
      restoreFocusedTarget = makeHashTargetTemporarilyFocusable(target);
      target.focus({ preventScroll: true });
    });
  }

  function scrollHashTargetIntoView(hash = window.location.hash) {
    const target = getHashTarget(hash);
    if (!target) {
      return;
    }

    requestAnimationFrame(() => {
      target.scrollIntoView({ block: 'start' });
    });
  }

  function normalizePathname(pathname: string) {
    return pathname === '/' ? '/' : `${pathname.replace(/\/+$/, '')}/`;
  }

  function isPlainPrimaryClick(event: MouseEvent) {
    return (
      !event.defaultPrevented &&
      event.button === 0 &&
      !event.metaKey &&
      !event.ctrlKey &&
      !event.shiftKey &&
      !event.altKey
    );
  }

  function focusMainContent() {
    const mainContent = document.getElementById('main-content');
    if (!(mainContent instanceof HTMLElement)) {
      return;
    }

    requestAnimationFrame(() => {
      mainContent.focus({ preventScroll: true });
    });
  }

  function resetScrollPosition() {
    window.scrollTo({ top: 0, left: 0 });
  }

  if (browser && hasConsent()) {
    void initPostHog('perfectmission.co.uk');
  }

  $effect(() => {
    if (!browser) {
      return;
    }

    const path = currentPath;
    const hash = currentHash;
    const previousPath = lastNavigationPath;
    const previousHash = lastNavigationHash;
    const hasPreviousNavigation = hasHandledNavigation;
    const pathChanged = hasPreviousNavigation && path !== previousPath;
    const hashCleared = hasPreviousNavigation && !hash && previousHash !== '';

    lastNavigationPath = path;
    lastNavigationHash = hash;
    hasHandledNavigation = true;

    void tick().then(() => {
      if (hash) {
        focusHashTarget(hash);
        return;
      }

      if (pathChanged || hashCleared) {
        if (hashCleared && !pathChanged) {
          resetScrollPosition();
        }

        focusMainContent();
      }
    });
  });

  onMount(() => {
    const handleDocumentClick = (event: MouseEvent) => {
      if (!isPlainPrimaryClick(event)) {
        return;
      }

      const trigger = event.target;
      if (!(trigger instanceof Element)) {
        return;
      }

      const link = trigger.closest<HTMLAnchorElement>('a[href]');
      if (
        !link ||
        link.origin !== window.location.origin ||
        normalizePathname(link.pathname) !== normalizePathname(window.location.pathname) ||
        link.search !== window.location.search ||
        link.hasAttribute('download') ||
        (link.target !== '' && link.target !== '_self')
      ) {
        return;
      }

      if (link.hash && link.hash === window.location.hash) {
        event.preventDefault();
        scrollHashTargetIntoView(link.hash);
        focusHashTarget(link.hash);
        return;
      }

      if (!link.hash && window.location.hash === '') {
        event.preventDefault();
        resetScrollPosition();
        focusMainContent();
      }
    };

    document.addEventListener('click', handleDocumentClick);

    return () => {
      restoreFocusedTarget?.();
      restoreFocusedTarget = null;
      document.removeEventListener('click', handleDocumentClick);
    };
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
<div class="page-shell">
  <Header currentPath={currentPath} currentHash={currentHash} />
  {@render children?.()}
  <Footer />
</div>
