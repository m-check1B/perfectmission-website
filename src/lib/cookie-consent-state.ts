function normalizeConsentPath(path: string) {
  return path === '/' ? '/' : `${path.replace(/\/+$/, '')}/`;
}

const NON_MODAL_CONSENT_PATHS = new Set(['/privacy/', '/terms/']);

export function shouldCookieBannerBeModal(currentPath: string) {
  return !NON_MODAL_CONSENT_PATHS.has(normalizeConsentPath(currentPath));
}
