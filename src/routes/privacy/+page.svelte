<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
</script>

<Seo
  title="Privacy Policy | Perfect Mission"
  description="Privacy policy for Perfect Mission Ltd - how we handle your data."
  canonicalPath="/privacy/"
/>

<main id="main-content" tabindex="-1">
    <section class="hero-section hero-section--detail">
      <div class="container detail-hero">
        <div>
          <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="/">Home</a>
            <span aria-hidden="true">/</span>
            <span aria-current="page">Privacy Policy</span>
          </nav>
          <h1>Privacy Policy</h1>
        </div>
      </div>
    </section>

    <section class="section section-stack">
      <div class="container two-column">
        <article class="content">
          <p class="last-updated">Last updated: March 2025</p>
          
          <h2>1. Introduction</h2>
          <p>
            Perfect Mission Ltd ("we", "us", or "our") is committed to protecting your privacy. 
            This Privacy Policy explains how we collect, use, and safeguard your information when 
            you visit our website perfectmission.co.uk.
          </p>

          <h2>2. Information We Collect</h2>
          <p>We may collect the following types of information:</p>
          <ul>
            <li><strong>Contact Information:</strong> Name, email address, and phone number when you contact us</li>
            <li><strong>Usage Data:</strong> Information about how you use our website</li>
            <li><strong>Technical Data:</strong> IP address, browser type, and device information</li>
          </ul>

          <h2>3. How We Use Your Information</h2>
          <p>We use your information to:</p>
          <ul>
            <li>Respond to your inquiries and provide our services</li>
            <li>Improve our website and user experience</li>
            <li>Send you relevant market intelligence updates (with your consent)</li>
            <li>Comply with legal obligations</li>
          </ul>

          <h2>4. Data Security</h2>
          <p>
            We implement appropriate technical and organizational measures to protect your 
            personal data against unauthorized access, alteration, disclosure, or destruction.
          </p>

          <h2>5. Your Rights</h2>
          <p>Under UK GDPR, you have the right to:</p>
          <ul>
            <li>Access your personal data</li>
            <li>Rectify inaccurate data</li>
            <li>Request erasure of your data</li>
            <li>Object to processing</li>
            <li>Request data portability</li>
          </ul>

          <h2>6. Contact Us</h2>
          <p>
            If you have any questions about this Privacy Policy, please contact us at 
            <a href="mailto:info@perfectmission.co.uk">info@perfectmission.co.uk</a>.
          </p>
        </article>

        <aside class="detail-summary">
          <p class="hero-panel__title">Key Points</p>
          <div class="detail-summary__row">
            <span>Data Controller</span>
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
            <span>DPO Contact</span>
            <strong>info@perfectmission.co.uk</strong>
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
