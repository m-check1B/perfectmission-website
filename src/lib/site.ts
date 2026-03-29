export const SITE_URL = 'https://perfectmission.co.uk';
export const SITE_NAME = 'Perfect Mission';
export const DEFAULT_OG_IMAGE = '/social/perfect-mission-og.png';
export const DEFAULT_ROBOTS = 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1';
export const COMPANY_EMAIL = 'info@perfectmission.co.uk';
export const COMPANY_LEGAL_NAME = 'Perfect Mission Ltd';
export const COMPANY_NUMBER = '08651715';
export const COMPANY_FOUNDERS = ['Matej Havlin', 'Lukas Havel'];

const COMPANY_ADDRESS = {
  '@type': 'PostalAddress',
  streetAddress: '20 Wenlock Road',
  addressLocality: 'London',
  postalCode: 'N1 7GU',
  addressCountry: 'GB'
};

const COVERED_COUNTRIES = [
  'Czech Republic',
  'Bulgaria',
  'Romania',
  'Poland',
  'Moldova',
  'Albania',
  'Honduras',
  'Dominican Republic',
  'Bolivia',
  'Panama',
  'Belize',
  'Cuba',
  'Vietnam',
  'Morocco'
].map((name) => ({
  '@type': 'Country',
  name
}));

export function normalizePath(path: string): string {
  if (!path || path === '/') return '/';

  const [pathname] = path.split(/[?#]/, 1);
  const cleaned = pathname.replace(/\/{2,}/g, '/');
  const looksLikeFile = /\/[^/]+\.[a-z0-9]+$/i.test(cleaned);

  if (cleaned === '') return '/';
  if (looksLikeFile) return cleaned;

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

export function buildBreadcrumbSchema(
  items: Array<{
    name: string;
    path: string;
  }>
) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: absoluteUrl(item.path)
    }))
  };
}

export const ORGANIZATION_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  '@id': `${SITE_URL}/#organization`,
  name: SITE_NAME,
  legalName: COMPANY_LEGAL_NAME,
  url: SITE_URL,
  logo: absoluteUrl('/favicon.svg'),
  email: COMPANY_EMAIL,
  address: COMPANY_ADDRESS,
  identifier: {
    '@type': 'PropertyValue',
    propertyID: 'Company Number',
    value: COMPANY_NUMBER
  },
  founders: COMPANY_FOUNDERS.map((name) => ({
    '@type': 'Person',
    name
  })),
  areaServed: COVERED_COUNTRIES,
  knowsAbout: [
    'emerging-market real estate',
    'cross-border investment screening',
    'real estate development consultancy',
    'market intelligence',
    'AI-assisted due diligence'
  ],
  contactPoint: [
    {
      '@type': 'ContactPoint',
      contactType: 'sales',
      email: COMPANY_EMAIL,
      availableLanguage: 'English',
      areaServed: COVERED_COUNTRIES
    }
  ]
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

export const PROFESSIONAL_SERVICE_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'ProfessionalService',
  '@id': `${SITE_URL}/#service`,
  name: `${SITE_NAME} real estate consultancy`,
  url: SITE_URL,
  description:
    'AI-driven real estate consultancy providing market intelligence, launch sequencing, and execution screening for cross-border development and investment decisions.',
  provider: {
    '@id': `${SITE_URL}/#organization`
  },
  areaServed: COVERED_COUNTRIES,
  address: COMPANY_ADDRESS,
  email: COMPANY_EMAIL,
  serviceType: [
    'Real estate consultancy',
    'Market intelligence',
    'Cross-border market screening',
    'Execution risk analysis'
  ]
};
