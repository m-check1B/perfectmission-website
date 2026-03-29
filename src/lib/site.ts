export const SITE_URL = 'https://perfectmission.co.uk';
export const SITE_NAME = 'Perfect Mission';
export const DEFAULT_OG_IMAGE = '/social/perfect-mission-og.png';
export const DEFAULT_ROBOTS = 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1';

export function normalizePath(path: string): string {
  if (!path || path === '/') return '/';

  const [pathname] = path.split(/[?#]/, 1);
  const cleaned = pathname.replace(/\/{2,}/g, '/');

  if (cleaned === '') return '/';
  if (cleaned.endsWith('.xml') || cleaned.endsWith('.txt')) return cleaned;

  return cleaned.endsWith('/') ? cleaned : `${cleaned}/`;
}

export function absoluteUrl(path: string): string {
  const normalized = normalizePath(path);
  return normalized === '/' ? SITE_URL : `${SITE_URL}${normalized}`;
}

export function buildWebPageSchema({
  title,
  description,
  path,
  image
}: {
  title: string;
  description: string;
  path: string;
  image?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    name: title,
    description,
    url: absoluteUrl(path),
    image: absoluteUrl(image ?? DEFAULT_OG_IMAGE),
    isPartOf: {
      '@id': `${SITE_URL}/#website`
    },
    about: {
      '@id': `${SITE_URL}/#organization`
    }
  };
}

export const ORGANIZATION_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  '@id': `${SITE_URL}/#organization`,
  name: SITE_NAME,
  url: SITE_URL,
  logo: absoluteUrl('/favicon.svg'),
  email: 'info@perfectmission.co.uk'
};

export const WEBSITE_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  '@id': `${SITE_URL}/#website`,
  name: SITE_NAME,
  url: SITE_URL,
  publisher: {
    '@id': `${SITE_URL}/#organization`
  }
};
