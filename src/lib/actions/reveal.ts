type RevealOptions = {
  delay?: number;
  once?: boolean;
  rootMargin?: string;
  threshold?: number;
};

const DEFAULT_OPTIONS: Required<RevealOptions> = {
  delay: 0,
  once: true,
  rootMargin: '0px 0px -12% 0px',
  threshold: 0.2
};

export function reveal(node: HTMLElement, options: RevealOptions = {}) {
  let observer: IntersectionObserver | undefined;
  let currentOptions = { ...DEFAULT_OPTIONS, ...options };
  const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');

  function applyDelay() {
    node.style.setProperty('--reveal-delay', `${currentOptions.delay}ms`);
  }

  function shouldSkipAnimation() {
    const bounds = node.getBoundingClientRect();
    return bounds.top < window.innerHeight;
  }

  function showImmediately() {
    node.classList.add('is-visible');
  }

  function cleanupObserver() {
    observer?.disconnect();
    observer = undefined;
  }

  function setupObserver() {
    cleanupObserver();
    applyDelay();

    if (reducedMotionQuery.matches || typeof IntersectionObserver === 'undefined') {
      showImmediately();
      return;
    }

    if (shouldSkipAnimation()) {
      showImmediately();
      return;
    }

    node.classList.remove('is-visible');
    observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting && entry.intersectionRatio >= currentOptions.threshold) {
            node.classList.add('is-visible');

            if (currentOptions.once) {
              observer?.unobserve(node);
            }
          } else if (!currentOptions.once) {
            node.classList.remove('is-visible');
          }
        }
      },
      {
        rootMargin: currentOptions.rootMargin,
        threshold: currentOptions.threshold
      }
    );

    observer.observe(node);
  }

  function handleMotionPreferenceChange() {
    setupObserver();
  }

  setupObserver();
  reducedMotionQuery.addEventListener('change', handleMotionPreferenceChange);

  return {
    destroy() {
      cleanupObserver();
      node.style.removeProperty('--reveal-delay');
      reducedMotionQuery.removeEventListener('change', handleMotionPreferenceChange);
    },
    update(nextOptions: RevealOptions = {}) {
      currentOptions = { ...DEFAULT_OPTIONS, ...nextOptions };
      setupObserver();
    }
  };
}
