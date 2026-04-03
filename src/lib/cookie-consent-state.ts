function normalizeConsentPath(path: string) {
  return path === '/' ? '/' : `${path.replace(/\/+$/, '')}/`;
}

const NON_MODAL_CONSENT_PATHS = new Set(['/privacy/', '/terms/']);

type SameTabNavigationClick = {
  altKey: boolean;
  button: number;
  ctrlKey: boolean;
  defaultPrevented: boolean;
  metaKey: boolean;
  shiftKey: boolean;
};

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

export function shouldReleaseCookieBannerForLinkNavigation(event: SameTabNavigationClick) {
  return (
    !event.defaultPrevented &&
    event.button === 0 &&
    !event.metaKey &&
    !event.ctrlKey &&
    !event.shiftKey &&
    !event.altKey
  );
}
