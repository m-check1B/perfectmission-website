import test from 'node:test';
import assert from 'node:assert/strict';

import {
  getFooterHrefAriaCurrent,
  getHeaderHrefAriaCurrent,
  getHomeBrandAriaCurrent,
  hasHashHrefMatch,
  isFooterHrefActive,
  isHashHrefActive,
  isHeaderHrefActive,
  isHomeBrandCurrent,
  normalizeNavPath
} from './navigation-state.ts';

const headerHashHrefs = ['/#contact'];

test('normalizeNavPath preserves root and normalizes trailing slashes', () => {
  assert.equal(normalizeNavPath('/'), '/');
  assert.equal(normalizeNavPath('/markets'), '/markets/');
  assert.equal(normalizeNavPath('/markets///'), '/markets/');
});

test('hash href activity requires matching normalized path and hash', () => {
  assert.equal(isHashHrefActive('/#contact', '/', '#contact'), true);
  assert.equal(isHashHrefActive('/#contact', '///', '#contact'), true);
  assert.equal(isHashHrefActive('/#contact', '/', '#about'), false);
  assert.equal(isHashHrefActive('/markets/#top', '/markets/', '#top'), true);
});

test('header navigation keeps overview active for unknown homepage hashes', () => {
  assert.equal(hasHashHrefMatch(headerHashHrefs, '/', '#about'), false);
  assert.equal(isHeaderHrefActive('/', '/', '#about', headerHashHrefs), true);
  assert.equal(getHeaderHrefAriaCurrent('/', '/', '#about', headerHashHrefs), 'location');
});

test('header navigation prioritizes explicit hash links and markets section paths', () => {
  assert.equal(isHeaderHrefActive('/#contact', '/', '#contact', headerHashHrefs), true);
  assert.equal(isHeaderHrefActive('/', '/', '#contact', headerHashHrefs), false);
  assert.equal(
    isHeaderHrefActive('/markets/', '/markets/czech-republic/', '', headerHashHrefs),
    true
  );
  assert.equal(
    getHeaderHrefAriaCurrent('/markets/', '/markets/czech-republic/', '', headerHashHrefs),
    'page'
  );
});

test('home brand is current only on the homepage without a hash', () => {
  assert.equal(isHomeBrandCurrent('/', ''), true);
  assert.equal(getHomeBrandAriaCurrent('/', ''), 'page');
  assert.equal(isHomeBrandCurrent('/', '#about'), false);
  assert.equal(getHomeBrandAriaCurrent('/', '#about'), undefined);
});

test('footer navigation stays exact and hash-specific', () => {
  assert.equal(isFooterHrefActive('/#about', '/', '#about'), true);
  assert.equal(getFooterHrefAriaCurrent('/#about', '/', '#about'), 'location');
  assert.equal(isFooterHrefActive('/markets/', '/markets/czech-republic/', ''), false);
  assert.equal(isFooterHrefActive('/markets/', '/markets/', ''), true);
  assert.equal(isFooterHrefActive('/markets/', '/markets/', '#summary'), false);
  assert.equal(getFooterHrefAriaCurrent('/markets/', '/markets/', ''), 'page');
});
