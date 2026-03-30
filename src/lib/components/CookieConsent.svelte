<script lang="ts">
  import { browser } from '$app/environment';
  import { onMount, tick } from 'svelte';
  import { initPostHog, needsConsentBanner, setConsent } from '$lib/posthog';

  let { site }: { site: string } = $props();
  let visible = $state(false);
  let dialogElement = $state<HTMLDivElement | undefined>(undefined);
  let lastFocusedElement: HTMLElement | null = null;

  if (browser) {
    visible = needsConsentBanner();
  }

  onMount(() => {
    return () => {
      if (document.body.dataset.cookieBannerOpen === 'true') {
        delete document.body.dataset.cookieBannerOpen;
      }
    };
  });

  $effect(() => {
    if (!browser || !visible) {
      return;
    }

    lastFocusedElement =
      document.activeElement instanceof HTMLElement ? document.activeElement : null;
    document.body.dataset.cookieBannerOpen = 'true';
    void focusBanner();

    return () => {
      delete document.body.dataset.cookieBannerOpen;
    };
  });

  async function focusBanner() {
    await tick();
    dialogElement?.focus();
  }

  async function closeBanner() {
    visible = false;
    await tick();
    lastFocusedElement?.focus();
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
    }
  }
</script>

{#if visible}
  <div class="cookie-banner-backdrop"></div>
  <div
    bind:this={dialogElement}
    class="cookie-banner"
    role="dialog"
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
          You can continue with essential cookies only. <a href="/privacy" class="cookie-link">Privacy Policy</a>
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
    pointer-events: none;
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
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
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
