<script lang="ts">
  import { browser } from '$app/environment';
  import { initPostHog, needsConsentBanner, setConsent } from '$lib/posthog';

  let { site }: { site: string } = $props();
  let visible = $state(false);

  if (browser) {
    visible = needsConsentBanner();
  }

  function accept() {
    setConsent('all');
    visible = false;
    initPostHog(site);
  }

  function reject() {
    setConsent('essential');
    visible = false;
  }
</script>

{#if visible}
  <div class="cookie-banner" role="dialog" aria-label="Cookie consent">
    <div class="cookie-content">
      <p>
        We use cookies to analyze site traffic and improve your experience.
        <a href="/privacy" class="cookie-link">Privacy Policy</a>
      </p>
      <div class="cookie-actions">
        <button class="btn-reject" onclick={reject}>Essential only</button>
        <button class="btn-accept" onclick={accept}>Accept analytics</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .cookie-banner {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 9999;
    background: rgba(10, 22, 40, 0.96);
    border-top: 1px solid var(--color-line-strong);
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
    max-width: 76rem;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
    flex-wrap: wrap;
  }

  .cookie-content p {
    margin: 0;
    font-size: 0.875rem;
    color: var(--color-text-secondary);
    font-family: var(--font-sans);
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
  .cookie-link:focus-visible {
    outline: 2px solid var(--color-accent);
    outline-offset: 3px;
  }

  @media (max-width: 600px) {
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
