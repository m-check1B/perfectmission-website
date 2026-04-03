<script lang="ts">
  import { browser } from '$app/environment';
  import { onMount, tick } from 'svelte';
  import { shouldCookieBannerBeModal } from '$lib/cookie-consent-state';
  import { initPostHog, needsConsentBanner, setConsent } from '$lib/posthog';

  let { site, currentPath = '/' }: { site: string; currentPath?: string } = $props();
  let visible = $state(false);
  let dialogElement = $state<HTMLDivElement | undefined>(undefined);
  let lastFocusedElement: HTMLElement | null = null;
  let pageShellElement: HTMLElement | null = null;
  let restoreAriaHidden: string | null = null;
  let backgroundInteractivityDisabled = false;
  const bannerIsModal = $derived(shouldCookieBannerBeModal(currentPath));

  if (browser) {
    visible = needsConsentBanner();
  }

  onMount(() => {
    if (browser) {
      pageShellElement = document.querySelector<HTMLElement>('.page-shell');
      if (visible && bannerIsModal) {
        disableBackgroundInteractivity();
      }
    }

    return () => {
      restoreBackgroundInteractivity();
      if (document.body.dataset.cookieBannerOpen === 'true') {
        delete document.body.dataset.cookieBannerOpen;
      }
    };
  });

  $effect(() => {
    if (!browser || !visible || !bannerIsModal) {
      return;
    }

    lastFocusedElement =
      document.activeElement instanceof HTMLElement ? document.activeElement : null;
    document.body.dataset.cookieBannerOpen = 'true';
    disableBackgroundInteractivity();
    void focusBanner();

    return () => {
      restoreBackgroundInteractivity();
      delete document.body.dataset.cookieBannerOpen;
    };
  });

  async function focusBanner() {
    await tick();
    dialogElement?.focus();
  }

  function disableBackgroundInteractivity() {
    if (!pageShellElement || backgroundInteractivityDisabled) {
      return;
    }

    restoreAriaHidden = pageShellElement.getAttribute('aria-hidden');
    pageShellElement.inert = true;
    pageShellElement.setAttribute('aria-hidden', 'true');
    backgroundInteractivityDisabled = true;
  }

  function restoreBackgroundInteractivity() {
    if (!pageShellElement || !backgroundInteractivityDisabled) {
      return;
    }

    pageShellElement.inert = false;

    if (restoreAriaHidden === null) {
      pageShellElement.removeAttribute('aria-hidden');
    } else {
      pageShellElement.setAttribute('aria-hidden', restoreAriaHidden);
    }

    restoreAriaHidden = null;
    backgroundInteractivityDisabled = false;
  }

  function getFocusableElements() {
    if (!dialogElement) {
      return [];
    }

    return Array.from(
      dialogElement.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );
  }

  function trapFocus(event: KeyboardEvent) {
    const focusableElements = getFocusableElements();
    if (focusableElements.length === 0) {
      event.preventDefault();
      dialogElement?.focus();
      return;
    }

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    const activeElement = document.activeElement;
    const focusInsideBanner =
      activeElement instanceof HTMLElement ? focusableElements.includes(activeElement) : false;

    if (!focusInsideBanner) {
      event.preventDefault();
      (event.shiftKey ? lastElement : firstElement).focus();
      return;
    }

    if (event.shiftKey && activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus();
    } else if (!event.shiftKey && activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus();
    }
  }

  function keepFocusInsideBanner() {
    if (!visible || !bannerIsModal) {
      return;
    }

    const activeElement = document.activeElement;
    if (activeElement instanceof HTMLElement && dialogElement?.contains(activeElement)) {
      return;
    }

    const [firstElement] = getFocusableElements();
    firstElement?.focus() ?? dialogElement?.focus();
  }

  function getRestoreFocusTarget() {
    if (
      lastFocusedElement &&
      lastFocusedElement.isConnected &&
      lastFocusedElement !== document.body &&
      lastFocusedElement !== document.documentElement
    ) {
      return lastFocusedElement;
    }

    const mainContent = document.getElementById('main-content');
    return mainContent instanceof HTMLElement ? mainContent : null;
  }

  function prepareForPolicyNavigation() {
    lastFocusedElement = null;
    restoreBackgroundInteractivity();
    delete document.body.dataset.cookieBannerOpen;
  }

  async function closeBanner() {
    visible = false;
    await tick();
    getRestoreFocusTarget()?.focus({ preventScroll: true });
    lastFocusedElement = null;
  }

  function accept() {
    setConsent('all');
    void initPostHog(site);
    void closeBanner();
  }

  function reject() {
    setConsent('essential');
    void closeBanner();
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      reject();
    } else if (event.key === 'Tab' && bannerIsModal) {
      trapFocus(event);
    }
  }

  function handleWindowFocusIn(event: FocusEvent) {
    if (!visible || !bannerIsModal) {
      return;
    }

    const target = event.target;
    if (target instanceof HTMLElement && dialogElement?.contains(target)) {
      return;
    }

    keepFocusInsideBanner();
  }
</script>

<svelte:window onfocusin={handleWindowFocusIn} />

{#if visible}
  <div class="cookie-banner-backdrop"></div>
  <div
    bind:this={dialogElement}
    class="cookie-banner"
    role="dialog"
    aria-modal={bannerIsModal ? 'true' : undefined}
    aria-labelledby="cookie-banner-title"
    aria-describedby="cookie-banner-description"
    tabindex="-1"
    onkeydown={handleKeydown}
  >
    <div class="cookie-content">
      <div class="cookie-copy">
        <p id="cookie-banner-title" class="cookie-title">Cookie preferences</p>
        <p id="cookie-banner-description">
          We use optional analytics cookies to understand site traffic and improve the experience.
          You can continue with essential cookies only. <a href="/privacy/" class="cookie-link" onclick={prepareForPolicyNavigation}>Privacy Policy</a>
        </p>
      </div>
      <div class="cookie-actions">
        <button type="button" class="btn-reject" onclick={reject}>Essential only</button>
        <button type="button" class="btn-accept" onclick={accept}>Accept analytics</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .cookie-banner-backdrop {
    position: fixed;
    inset: 0;
    z-index: 9998;
    background:
      linear-gradient(180deg, rgba(7, 15, 28, 0.1) 0%, rgba(7, 15, 28, 0.45) 100%);
    pointer-events: auto;
  }

  .cookie-banner {
    position: fixed;
    left: 50%;
    bottom: 1.5rem;
    width: min(calc(100vw - 2rem), 52rem);
    transform: translateX(-50%);
    z-index: 9999;
    background: rgba(10, 22, 40, 0.96);
    border: 1px solid var(--color-line-strong);
    border-radius: 1rem;
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    padding: 1rem 1.5rem;
    box-shadow: 0 -4px 30px rgba(184, 122, 58, 0.08);
    animation: slide-up 0.3s ease;
  }

  @keyframes slide-up {
    from { transform: translateX(-50%) translateY(100%); }
    to { transform: translateX(-50%) translateY(0); }
  }

  .cookie-content {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 1.5rem;
    flex-wrap: wrap;
  }

  .cookie-copy {
    flex: 1 1 24rem;
  }

  .cookie-content p {
    margin: 0;
    font-size: 0.875rem;
    color: var(--color-text-secondary);
    font-family: var(--font-sans);
  }

  .cookie-title {
    margin-bottom: 0.35rem;
    color: var(--color-text);
    font-size: 0.95rem;
    font-weight: 600;
    letter-spacing: 0.01em;
  }

  .cookie-link {
    color: var(--color-accent-light);
    text-decoration: underline;
  }

  .cookie-actions {
    display: flex;
    gap: 0.75rem;
    flex-shrink: 0;
    align-items: stretch;
  }

  .btn-reject {
    min-height: 2.75rem;
    padding: 0.625rem 1rem;
    border: 1px solid var(--color-line);
    background: transparent;
    color: var(--color-text-secondary);
    border-radius: var(--radius-sm);
    font-size: 0.875rem;
    font-weight: 500;
    font-family: var(--font-sans);
    cursor: pointer;
    transition: border-color 0.2s, color 0.2s, background 0.2s;
  }

  .btn-reject:hover {
    border-color: var(--color-line-strong);
    color: var(--color-text);
    background: rgba(255, 255, 255, 0.04);
  }

  .btn-accept {
    min-height: 2.75rem;
    padding: 0.625rem 1rem;
    background: var(--color-accent);
    color: var(--color-text-dark);
    border: none;
    border-radius: var(--radius-sm);
    font-size: 0.875rem;
    font-weight: 600;
    font-family: var(--font-sans);
    cursor: pointer;
    transition: background 0.2s, color 0.2s;
  }

  .btn-accept:hover {
    background: var(--color-accent-light);
  }

  .btn-reject:focus-visible,
  .btn-accept:focus-visible,
  .cookie-banner:focus-visible,
  .cookie-link:focus-visible {
    outline: 2px solid var(--color-accent);
    outline-offset: 3px;
  }

  @media (max-width: 600px) {
    .cookie-banner {
      bottom: 1rem;
      width: min(calc(100vw - 1rem), 52rem);
      padding: 1rem;
    }

    .cookie-content {
      flex-direction: column;
      align-items: flex-start;
    }

    .cookie-actions {
      width: 100%;
      flex-direction: column;
    }

    .btn-reject,
    .btn-accept {
      width: 100%;
    }
  }
</style>
