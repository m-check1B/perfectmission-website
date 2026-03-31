<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
</script>

<Seo
  title="Terms of Service | Perfect Mission"
  description="Terms of Service for Perfect Mission Ltd - conditions for using our website and services."
  canonicalPath="/terms/"
/>

<main id="main-content" tabindex="-1">
    <section class="hero-section hero-section--detail">
      <div class="container detail-hero">
        <div>
          <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="/">Home</a>
            <span aria-hidden="true">/</span>
            <span aria-current="page">Terms of Service</span>
          </nav>
          <h1>Terms of Service</h1>
        </div>
      </div>
    </section>

    <section class="section section-stack">
      <div class="container two-column">
        <article class="content">
          <p class="last-updated">Last updated: March 2025</p>
          
          <h2>1. Acceptance of Terms</h2>
          <p>
            By accessing and using the website perfectmission.co.uk ("the Website"), you accept 
            and agree to be bound by these Terms of Service. If you do not agree to these terms, 
            please do not use the Website.
          </p>

          <h2>2. Company Information</h2>
          <p>
            Perfect Mission Ltd is a company registered in England and Wales with company number 
            08651715. Our registered address is 20 Wenlock Road, London N1 7GU, United Kingdom.
          </p>

          <h2>3. Use of Website</h2>
          <p>You agree to use the Website only for lawful purposes and in a way that does not:</p>
          <ul>
            <li>Infringe the rights of any third party</li>
            <li>Violate any applicable local, national, or international law</li>
            <li>Transmit any harmful or malicious code</li>
            <li>Attempt to gain unauthorized access to any part of the Website</li>
          </ul>

          <h2>4. Intellectual Property</h2>
          <p>
            All content on the Website, including text, graphics, logos, and market intelligence 
            reports, is the property of Perfect Mission Ltd and is protected by copyright and other 
            intellectual property laws. You may not reproduce, distribute, or create derivative 
            works without our express written permission.
          </p>

          <h2>5. Disclaimer</h2>
          <p>
            The information provided on the Website is for general informational purposes only 
            and does not constitute investment advice. While we strive to ensure accuracy, we make 
            no warranties about the completeness, reliability, or accuracy of this information.
          </p>

          <h2>6. Limitation of Liability</h2>
          <p>
            Perfect Mission Ltd shall not be liable for any indirect, incidental, special, 
            consequential, or punitive damages resulting from your use of or inability to use 
            the Website or our services.
          </p>

          <h2>7. Governing Law</h2>
          <p>
            These Terms of Service are governed by and construed in accordance with the laws of 
            England and Wales. Any disputes shall be subject to the exclusive jurisdiction of the 
            courts of England and Wales.
          </p>

          <h2>8. Changes to Terms</h2>
          <p>
            We reserve the right to modify these terms at any time. Changes will be effective 
            immediately upon posting to the Website. Your continued use of the Website constitutes 
            acceptance of the revised terms.
          </p>

          <h2>9. Contact Information</h2>
          <p>
            For any questions about these Terms of Service, please contact us at 
            <a href="mailto:info@perfectmission.co.uk">info@perfectmission.co.uk</a>.
          </p>
        </article>

        <aside class="detail-summary">
          <p class="hero-panel__title">Key Information</p>
          <div class="detail-summary__row">
            <span>Company</span>
            <strong>Perfect Mission Ltd</strong>
          </div>
          <div class="detail-summary__row">
            <span>Registered</span>
            <strong>England & Wales</strong>
          </div>
          <div class="detail-summary__row">
            <span>Company No.</span>
            <strong>08651715</strong>
          </div>
          <div class="detail-summary__row">
            <span>Address</span>
            <strong>20 Wenlock Road, London N1 7GU</strong>
          </div>
          <div class="detail-summary__row">
            <span>Governing Law</span>
            <strong>England & Wales</strong>
          </div>
        </aside>
      </div>
    </section>
  </main>

<style>
  .content {
    max-width: 60ch;
  }
  
  .content h2 {
    font-size: 1.5rem;
    margin: 2.5rem 0 1rem;
    color: var(--color-text);
  }
  
  .content h2:first-of-type {
    margin-top: 1.5rem;
  }
  
  .content p {
    margin: 0 0 1rem;
    line-height: 1.8;
  }
  
  .content ul {
    margin: 0 0 1.5rem;
    padding-left: 1.5rem;
  }
  
  .content li {
    margin: 0.5rem 0;
    line-height: 1.7;
  }
  
  .content a {
    color: var(--color-accent-soft);
    text-decoration: underline;
    text-underline-offset: 0.2em;
  }
  
  .content a:hover {
    color: var(--color-accent);
  }
  
  .last-updated {
    color: var(--color-accent-soft);
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 1rem;
  }
</style>
