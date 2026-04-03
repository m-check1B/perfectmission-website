import test from 'node:test';
import assert from 'node:assert/strict';

import {
  getCookieBannerPresentation,
  shouldCookieBannerBeModal
} from './cookie-consent-state.ts';

test('cookie banner stays modal on product routes', () => {
  assert.equal(shouldCookieBannerBeModal('/'), true);
  assert.equal(shouldCookieBannerBeModal('/markets/czech-republic/'), true);
  assert.deepEqual(getCookieBannerPresentation('/markets/czech-republic/'), {
    isModal: true,
    lockBackground: true,
    showBackdrop: true
  });
});

test('cookie banner becomes non-modal on legal document routes', () => {
  assert.equal(shouldCookieBannerBeModal('/privacy'), false);
  assert.equal(shouldCookieBannerBeModal('/privacy/'), false);
  assert.equal(shouldCookieBannerBeModal('/terms/'), false);
  assert.deepEqual(getCookieBannerPresentation('/privacy/'), {
    isModal: false,
    lockBackground: false,
    showBackdrop: false
  });
});
