import { shouldDeferHashActivationForCookieBanner } from './cookie-consent-state.ts';

export type MarketSourceAnchorItem = {
  id: string;
};

export function normalizeSourceAnchorSuffix(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export function getStableSourceAnchorSuffix(source: MarketSourceAnchorItem, index: number) {
  const normalizedId = normalizeSourceAnchorSuffix(source.id);

  // Keep stable IDs distinct from the legacy numeric hash format.
  if (!normalizedId || /^\d+$/.test(normalizedId)) {
    return `entry-${index + 1}`;
  }

  return normalizedId;
}

export function buildSourceItemIds(
  sources: MarketSourceAnchorItem[],
  sourceItemIdPrefix = 'market-source-'
) {
  const usedSuffixes = new Set<string>();

  return sources.map((source, index) => {
    const baseSuffix = getStableSourceAnchorSuffix(source, index);
    let uniqueSuffix = baseSuffix;
    let collisionIndex = 2;

    while (usedSuffixes.has(uniqueSuffix)) {
      uniqueSuffix = `${baseSuffix}-${collisionIndex}`;
      collisionIndex += 1;
    }

    usedSuffixes.add(uniqueSuffix);

    return `${sourceItemIdPrefix}${uniqueSuffix}`;
  });
}

export function decodeHashTargetId(hash: string) {
  try {
    return decodeURIComponent(hash.slice(1));
  } catch {
    return null;
  }
}

export function getLegacySourceIndex(hash: string, sourceItemIdPrefix = 'market-source-') {
  const targetId = decodeHashTargetId(hash);
  if (!targetId?.startsWith(sourceItemIdPrefix)) {
    return null;
  }

  const legacySuffix = targetId.slice(sourceItemIdPrefix.length);
  if (!/^\d+$/.test(legacySuffix)) {
    return null;
  }

  const legacyIndex = Number(legacySuffix) - 1;
  return legacyIndex >= 0 ? legacyIndex : null;
}

export function isLegacySourceHash(hash: string, sourceItemIdPrefix = 'market-source-') {
  return getLegacySourceIndex(hash, sourceItemIdPrefix) !== null;
}

export function shouldRevealLegacySourceHash(
  hash: string,
  currentPath: string,
  consentBannerVisible: boolean,
  sourceItemIdPrefix = 'market-source-'
) {
  return (
    isLegacySourceHash(hash, sourceItemIdPrefix) &&
    !shouldDeferHashActivationForCookieBanner(currentPath, consentBannerVisible)
  );
}
