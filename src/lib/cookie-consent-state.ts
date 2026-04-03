function normalizeConsentPath(path: string) {
  return path === '/' ? '/' : `${path.replace(/\/+$/, '')}/`;
}

const NON_MODAL_CONSENT_PATHS = new Set(['/privacy/', '/terms/']);

export function getCookieBannerPresentation(currentPath: string) {
  const isModal = !NON_MODAL_CONSENT_PATHS.has(normalizeConsentPath(currentPath));

  return {
    isModal,
    lockBackground: isModal,
    showBackdrop: isModal
  };
}

export function shouldCookieBannerBeModal(currentPath: string) {
  return getCookieBannerPresentation(currentPath).isModal;
}
