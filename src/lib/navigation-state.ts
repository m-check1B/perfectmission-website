export function normalizeNavPath(path: string) {
  return path === '/' ? '/' : `${path.replace(/\/+$/, '')}/`;
}

export function isHashHrefActive(href: string, currentPath: string, currentHash: string) {
  if (!href.includes('#')) {
    return false;
  }

  const [path, hash] = href.split('#');
  const resolvedPath = normalizeNavPath(path || '/');
  return normalizeNavPath(currentPath) === resolvedPath && currentHash === `#${hash}`;
}

export function hasHashHrefMatch(hrefs: string[], currentPath: string, currentHash: string) {
  return hrefs.some((href) => isHashHrefActive(href, currentPath, currentHash));
}

export function isHomeBrandCurrent(currentPath: string, currentHash: string) {
  return normalizeNavPath(currentPath) === '/' && currentHash === '';
}

export function getHomeBrandAriaCurrent(currentPath: string, currentHash: string) {
  return isHomeBrandCurrent(currentPath, currentHash) ? 'page' : undefined;
}

export function isHeaderHrefActive(
  href: string,
  currentPath: string,
  currentHash: string,
  headerHashHrefs: string[]
) {
  if (href.startsWith('mailto:')) {
    return false;
  }

  if (href.includes('#')) {
    return isHashHrefActive(href, currentPath, currentHash);
  }

  const normalizedCurrentPath = normalizeNavPath(currentPath);
  if (href === '/') {
    return normalizedCurrentPath === '/' && !hasHashHrefMatch(headerHashHrefs, currentPath, currentHash);
  }

  const resolvedPath = normalizeNavPath(href);
  return normalizedCurrentPath === resolvedPath || normalizedCurrentPath.startsWith(`${resolvedPath}`);
}

export function getHeaderHrefAriaCurrent(
  href: string,
  currentPath: string,
  currentHash: string,
  headerHashHrefs: string[]
) {
  if (!isHeaderHrefActive(href, currentPath, currentHash, headerHashHrefs)) {
    return undefined;
  }

  if (href.includes('#')) {
    return 'location';
  }

  if (href === '/' && normalizeNavPath(currentPath) === '/' && currentHash !== '') {
    return 'location';
  }

  return 'page';
}

export function isFooterHrefActive(href: string, currentPath: string, currentHash: string) {
  if (href.startsWith('mailto:')) {
    return false;
  }

  if (href.includes('#')) {
    return isHashHrefActive(href, currentPath, currentHash);
  }

  return normalizeNavPath(currentPath) === normalizeNavPath(href) && currentHash === '';
}

export function getFooterHrefAriaCurrent(href: string, currentPath: string, currentHash: string) {
  if (!isFooterHrefActive(href, currentPath, currentHash)) {
    return undefined;
  }

  return href.includes('#') ? 'location' : 'page';
}
