import test from 'node:test';
import assert from 'node:assert/strict';

import {
  buildSourceItemIds,
  decodeHashTargetId,
  getLegacySourceIndex,
  isLegacySourceHash,
  shouldRevealLegacySourceHash
} from './market-source-anchors.ts';

test('buildSourceItemIds keeps generated duplicate suffixes distinct from natural suffixed ids', () => {
  const ids = buildSourceItemIds([
    { id: 'foo' },
    { id: 'foo' },
    { id: 'foo-2' },
    { id: '123' },
    { id: 'entry-4' },
    { id: 'entry-4' }
  ]);

  assert.deepEqual(ids, [
    'market-source-foo',
    'market-source-foo-2',
    'market-source-foo-2-2',
    'market-source-entry-4',
    'market-source-entry-4-2',
    'market-source-entry-4-3'
  ]);
});

test('decodeHashTargetId returns null for malformed percent-encoded hashes', () => {
  assert.equal(decodeHashTargetId('#%E0%A4%A'), null);
});

test('legacy hash helpers only accept positive numeric source suffixes', () => {
  assert.equal(getLegacySourceIndex('#market-source-3'), 2);
  assert.equal(getLegacySourceIndex('#market-source-0'), null);
  assert.equal(getLegacySourceIndex('#market-source-cz_deloitte_property'), null);
  assert.equal(isLegacySourceHash('#market-source-3'), true);
  assert.equal(isLegacySourceHash('#market-source-cz_deloitte_property'), false);
});

test('legacy source hash reveal defers behind a blocking cookie banner', () => {
  assert.equal(
    shouldRevealLegacySourceHash('#market-source-3', '/markets/czech-republic/', true),
    false
  );
  assert.equal(
    shouldRevealLegacySourceHash('#market-source-3', '/markets/czech-republic/', false),
    true
  );
  assert.equal(
    shouldRevealLegacySourceHash('#market-source-3', '/privacy/', true),
    true
  );
  assert.equal(
    shouldRevealLegacySourceHash('#market-source-cz_deloitte_property', '/markets/czech-republic/', false),
    false
  );
});
