import { marketIndex, markets } from '$lib/market-intelligence';
import { SITE_URL } from '$lib/site';

export const prerender = true;

type SitemapEntry = {
  path: string;
  lastmod?: string;
  changefreq?: string;
  priority?: string;
};

const staticEntries: SitemapEntry[] = [
  {
    path: '/',
    lastmod: marketIndex.last_updated,
    changefreq: 'weekly',
    priority: '1.0'
  },
  {
    path: '/markets/',
    lastmod: marketIndex.last_updated,
    changefreq: 'weekly',
    priority: '0.9'
  },
  {
    path: '/privacy/',
    changefreq: 'yearly',
    priority: '0.3'
  },
  {
    path: '/terms/',
    changefreq: 'yearly',
    priority: '0.3'
  }
];

function escapeXml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
}

function toAbsoluteUrl(path: string) {
  return path === '/' ? SITE_URL : `${SITE_URL}${path}`;
}

function renderEntry(entry: SitemapEntry) {
  const fields = [
    `<loc>${escapeXml(toAbsoluteUrl(entry.path))}</loc>`,
    entry.lastmod ? `<lastmod>${escapeXml(entry.lastmod)}</lastmod>` : '',
    entry.changefreq ? `<changefreq>${entry.changefreq}</changefreq>` : '',
    entry.priority ? `<priority>${entry.priority}</priority>` : ''
  ]
    .filter(Boolean)
    .join('');

  return `<url>${fields}</url>`;
}

export function GET() {
  const marketEntries: SitemapEntry[] = markets.map((market) => ({
    path: `/markets/${market.slug}/`,
    lastmod: market.last_updated,
    changefreq: 'weekly',
    priority: market.priority_rank <= 3 ? '0.8' : '0.7'
  }));

  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...[...staticEntries, ...marketEntries].map(renderEntry),
    '</urlset>'
  ].join('');

  return new Response(body, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8'
    }
  });
}
