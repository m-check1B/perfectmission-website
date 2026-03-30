import { error } from '@sveltejs/kit';
import { getMarketBySlug, marketSlugs } from '$lib/market-intelligence';

export const prerender = true;
export const entries = () => marketSlugs.map((slug) => ({ slug }));

export function load({ params }) {
  const market = getMarketBySlug(params.slug);

  if (!market) {
    error(404, 'Market not found');
  }

  return { market };
}
