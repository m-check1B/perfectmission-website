<script lang="ts">
  let {
    currentPath = '/',
    currentHash = ''
  }: { currentPath?: string; currentHash?: string } = $props();

  const currentYear = new Date().getFullYear();

  function normalizePath(path: string) {
    return path === '/' ? '/' : `${path.replace(/\/+$/, '')}/`;
  }

  function isActive(href: string) {
    if (href.startsWith('mailto:')) {
      return false;
    }

    const [path, hash] = href.split('#');
    const resolvedPath = normalizePath(path || '/');

    if (hash) {
      return currentPath === resolvedPath && currentHash === `#${hash}`;
    }

    return currentPath === resolvedPath && !currentHash;
  }

  function getAriaCurrent(href: string) {
    if (!isActive(href)) {
      return undefined;
    }

    return href.includes('#') ? 'location' : 'page';
  }
</script>

<footer class="site-footer">
  <div class="container">
    <div class="site-footer__grid">
      <div class="site-footer__brand">
        <a class="brand" href="/">
          Perfect<span>Mission</span>
        </a>
        <p class="site-footer__tagline">
          Market intelligence for cross-border real estate decisions.
        </p>
      </div>
      
      <div class="site-footer__section">
        <p class="site-footer__title">Markets</p>
        <ul class="site-footer__links">
          <li><a href="/markets/" class:active={isActive('/markets/')} aria-current={getAriaCurrent('/markets/')}>All markets</a></li>
          <li><a href="/markets/bulgaria/" class:active={isActive('/markets/bulgaria/')} aria-current={getAriaCurrent('/markets/bulgaria/')}>Bulgaria</a></li>
          <li><a href="/markets/romania/" class:active={isActive('/markets/romania/')} aria-current={getAriaCurrent('/markets/romania/')}>Romania</a></li>
          <li><a href="/markets/morocco/" class:active={isActive('/markets/morocco/')} aria-current={getAriaCurrent('/markets/morocco/')}>Morocco</a></li>
          <li><a href="/markets/albania/" class:active={isActive('/markets/albania/')} aria-current={getAriaCurrent('/markets/albania/')}>Albania</a></li>
        </ul>
      </div>
      
      <div class="site-footer__section">
        <p class="site-footer__title">Company</p>
        <ul class="site-footer__links">
          <li><a href="/#about" class:active={isActive('/#about')} aria-current={getAriaCurrent('/#about')}>About</a></li>
          <li><a href="/#contact" class:active={isActive('/#contact')} aria-current={getAriaCurrent('/#contact')}>Contact</a></li>
          <li><a href="mailto:info@perfectmission.co.uk">Email us</a></li>
        </ul>
      </div>
      
      <div class="site-footer__section">
        <p class="site-footer__title">Legal</p>
        <ul class="site-footer__links">
          <li><a href="/privacy/" class:active={isActive('/privacy/')} aria-current={getAriaCurrent('/privacy/')}>Privacy Policy</a></li>
          <li><a href="/terms/" class:active={isActive('/terms/')} aria-current={getAriaCurrent('/terms/')}>Terms of Service</a></li>
        </ul>
        <address class="site-footer__address">
          20 Wenlock Road<br>
          London N1 7GU<br>
          United Kingdom<br>
          <span class="site-footer__reg">Reg. England & Wales No. 08651715</span>
        </address>
      </div>
    </div>
    
    <div class="site-footer__bottom">
      <p>&copy; {currentYear} Perfect Mission Ltd. All rights reserved.</p>
      <a href="mailto:info@perfectmission.co.uk" class="site-footer__email">
        info@perfectmission.co.uk
      </a>
    </div>
  </div>
</footer>

<style>
  .site-footer__grid {
    display: grid;
    grid-template-columns: 2fr repeat(3, 1fr);
    gap: 3rem;
    padding-bottom: 3rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  }
  
  .site-footer__brand .brand {
    font-size: 1.5rem;
    margin-bottom: 1rem;
    display: inline-block;
  }
  
  .site-footer__tagline {
    max-width: 280px;
    font-size: 0.95rem;
    margin: 0;
  }
  
  .site-footer__section {
    display: flex;
    flex-direction: column;
  }
  
  .site-footer__links {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .site-footer__links a {
    color: var(--color-text-muted);
    font-size: 0.9rem;
    transition: all var(--transition-fast);
    position: relative;
    display: inline-block;
  }
  
  .site-footer__links a::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    width: 0;
    height: 1px;
    background: var(--color-accent);
    transition: width var(--transition-fast);
  }
  
  .site-footer__links a:hover {
    color: var(--color-text);
  }
  
  .site-footer__links a.active {
    color: var(--color-text);
  }

  .site-footer__links a:hover::after {
    width: 100%;
  }

  .site-footer__links a.active::after {
    width: 100%;
  }
  
  .site-footer__address {
    margin-top: 1.5rem;
    font-style: normal;
    font-size: 0.85rem;
    color: var(--color-text-muted);
    line-height: 1.7;
  }
  
  .site-footer__reg {
    display: block;
    margin-top: 0.5rem;
    font-size: 0.8rem;
    opacity: 0.8;
  }
  
  .site-footer__bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 2rem;
    gap: 2rem;
    flex-wrap: wrap;
  }
  
  .site-footer__bottom p {
    margin: 0;
    font-size: 0.85rem;
    color: var(--color-text-muted);
  }
  
  .site-footer__email {
    color: var(--color-accent-soft);
    font-weight: 500;
    transition: color var(--transition-fast);
  }
  
  .site-footer__email:hover {
    color: var(--color-accent);
  }
  
  @media (max-width: 900px) {
    .site-footer__grid {
      grid-template-columns: repeat(2, 1fr);
      gap: 2.5rem;
    }
    
    .site-footer__brand {
      grid-column: 1 / -1;
    }
  }
  
  @media (max-width: 640px) {
    .site-footer__grid {
      grid-template-columns: 1fr;
      gap: 2rem;
    }
    
    .site-footer__bottom {
      flex-direction: column;
      text-align: center;
      gap: 1rem;
    }
  }
</style>
