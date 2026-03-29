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
        <a href="mailto:info@perfectmission.co.uk?subject=Privacy%20Policy%20request">Privacy Policy</a>
      </p>
      <div class="cookie-actions">
        <button class="btn-reject" onclick={reject}>Essential only</button>
        <button class="btn-accept" onclick={accept}>Accept analytics</button>
      </div>
    </div>
  </div>
{/if}
