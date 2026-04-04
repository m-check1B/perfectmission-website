#!/usr/bin/env node

import process from 'node:process';

const DEFAULT_BASE_URL = 'http://127.0.0.1:4175/';
const DEFAULT_BROWSER = process.env.PLAYWRIGHT_BROWSER ?? 'chromium';
const CONSENT_KEY = 'perfectmission_cookie_consent';
const STABLE_SOURCE_TARGET_ID = 'market-source-cz_deloitte_property';
const LEGACY_SOURCE_HASH = '#market-source-3';
const MALFORMED_SOURCE_HASH = '#%E0%A4%A';
const MARKET_PATH = '/markets/czech-republic/';
const STORED_CONSENT_VALUE = 'essential';

function printUsage() {
  console.log(`Usage: node scripts/verify-market-source-hashes.mjs [base-url]

Runs a fresh-consent browser verification against the Czech market page and asserts:
- the blocking cookie banner keeps focus away from the stable source hash target
- the blocking cookie banner keeps focus away from the legacy numeric hash target
- the blocking cookie banner keeps focus away from malformed source hashes
- dismissing the banner opens the expected source disclosure and focuses it
- the legacy numeric hash is canonicalized to the stable source id after dismissal
- dismissing the banner with a malformed hash leaves focus on the main content without opening a source
- an existing essential-only consent opens stable and legacy source deep links without showing the banner

Examples:
  npm run verify:market-source-hashes
  npm run verify:market-source-hashes -- http://127.0.0.1:4175/
  PLAYWRIGHT_BROWSER=webkit npm run verify:market-source-hashes
`);
}

function getBaseUrl(argument) {
  return argument ?? process.env.PERFECTMISSION_BASE_URL ?? DEFAULT_BASE_URL;
}

function ensure(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

async function loadPlaywright() {
  try {
    return await import('playwright');
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(
      `Playwright could not be loaded. Run this script via \`npm run verify:market-source-hashes\` or install Playwright first.\n${message}`
    );
  }
}

function getBrowserType(playwright, browserName) {
  const browserType = playwright[browserName];

  if (!browserType) {
    throw new Error(
      `Unsupported PLAYWRIGHT_BROWSER "${browserName}". Use one of: chromium, firefox, webkit.`
    );
  }

  return browserType;
}

async function withFreshPage(browserType, baseUrl, run, options = {}) {
  let browser;
  let context;
  const consentValue = options.consent ?? null;

  try {
    browser = await browserType.launch({ headless: true });
    context = await browser.newContext({ baseURL: baseUrl });

    if (consentValue) {
      await context.addInitScript(
        ({ key, value }) => {
          try {
            window.localStorage.setItem(key, value);
          } catch {
            // Ignore storage errors so the verifier still reports the real browser failure.
          }
        },
        { key: CONSENT_KEY, value: consentValue }
      );
    }

    const page = await context.newPage();
    page.setDefaultTimeout(10000);
    return await run(page);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const installHint = message.includes("Executable doesn't exist")
      ? `\nInstall the missing browser with: npx playwright install ${browserType.name()}`
      : '';
    throw new Error(`Failed to launch or use Playwright ${browserType.name()}: ${message}${installHint}`);
  } finally {
    await context?.close().catch(() => {});
    await browser?.close().catch(() => {});
  }
}

async function verifyStableHashFlow(page) {
  await page.goto(`${MARKET_PATH}#${STABLE_SOURCE_TARGET_ID}`, { waitUntil: 'load' });
  await page.waitForFunction(
    (targetId) => {
      const target = document.getElementById(targetId);
      return !!document.querySelector('.cookie-banner') && target instanceof HTMLDetailsElement;
    },
    STABLE_SOURCE_TARGET_ID
  );

  const beforeDismiss = await page.evaluate((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return {
      activeInBanner:
        activeElement instanceof Element ? !!activeElement.closest('.cookie-banner') : false,
      bannerVisible: !!document.querySelector('.cookie-banner'),
      hash: window.location.hash,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      targetOpen: target instanceof HTMLDetailsElement ? target.open : null,
      targetContainsFocus:
        target instanceof Element && activeElement instanceof Element ? target.contains(activeElement) : false
    };
  }, STABLE_SOURCE_TARGET_ID);

  ensure(beforeDismiss.bannerVisible, 'Stable hash flow: cookie banner was not visible on first load.');
  ensure(beforeDismiss.modalLockActive, 'Stable hash flow: cookie banner did not lock the page shell.');
  ensure(beforeDismiss.activeInBanner, 'Stable hash flow: initial focus escaped the cookie banner.');
  ensure(
    beforeDismiss.hash === `#${STABLE_SOURCE_TARGET_ID}`,
    `Stable hash flow: expected hash "#${STABLE_SOURCE_TARGET_ID}", got "${beforeDismiss.hash}".`
  );
  ensure(beforeDismiss.targetOpen === false, 'Stable hash flow: source disclosure opened before consent dismissal.');
  ensure(
    beforeDismiss.targetContainsFocus === false,
    'Stable hash flow: source disclosure received focus before consent dismissal.'
  );

  await page.getByRole('button', { name: 'Essential only' }).click();
  await page.waitForFunction((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return (
      !document.querySelector('.cookie-banner') &&
      document.body.dataset.cookieBannerOpen !== 'true' &&
      target instanceof HTMLDetailsElement &&
      target.open &&
      activeElement instanceof Element &&
      target.contains(activeElement)
    );
  }, STABLE_SOURCE_TARGET_ID);
}

async function verifyStableHashFlowWithStoredConsent(page) {
  await page.goto(`${MARKET_PATH}#${STABLE_SOURCE_TARGET_ID}`, { waitUntil: 'load' });
  await page.waitForFunction((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return (
      !document.querySelector('.cookie-banner') &&
      document.body.dataset.cookieBannerOpen !== 'true' &&
      target instanceof HTMLDetailsElement &&
      target.open &&
      activeElement instanceof Element &&
      target.contains(activeElement)
    );
  }, STABLE_SOURCE_TARGET_ID);

  const afterLoad = await page.evaluate((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return {
      bannerVisible: !!document.querySelector('.cookie-banner'),
      hash: window.location.hash,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      targetContainsFocus:
        target instanceof Element && activeElement instanceof Element ? target.contains(activeElement) : false,
      targetOpen: target instanceof HTMLDetailsElement ? target.open : null
    };
  }, STABLE_SOURCE_TARGET_ID);

  ensure(afterLoad.bannerVisible === false, 'Stored-consent stable hash flow: cookie banner was still visible.');
  ensure(
    afterLoad.modalLockActive === false,
    'Stored-consent stable hash flow: cookie banner lock was still active.'
  );
  ensure(
    afterLoad.hash === `#${STABLE_SOURCE_TARGET_ID}`,
    `Stored-consent stable hash flow: expected hash "#${STABLE_SOURCE_TARGET_ID}", got "${afterLoad.hash}".`
  );
  ensure(afterLoad.targetOpen === true, 'Stored-consent stable hash flow: source disclosure did not open.');
  ensure(
    afterLoad.targetContainsFocus,
    'Stored-consent stable hash flow: focus did not land inside the source disclosure.'
  );
}

async function verifyLegacyHashFlow(page) {
  await page.goto(`${MARKET_PATH}${LEGACY_SOURCE_HASH}`, { waitUntil: 'load' });
  await page.waitForFunction(() => !!document.querySelector('.cookie-banner'));

  const expectedTargetId = await page.evaluate(() => {
    const thirdSource = document.querySelectorAll('details.source-disclosure').item(2);
    return thirdSource instanceof HTMLDetailsElement ? thirdSource.id : null;
  });

  ensure(expectedTargetId, 'Legacy hash flow: could not resolve the third market source disclosure id.');

  const beforeDismiss = await page.evaluate((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return {
      activeInBanner:
        activeElement instanceof Element ? !!activeElement.closest('.cookie-banner') : false,
      bannerVisible: !!document.querySelector('.cookie-banner'),
      hash: window.location.hash,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      targetOpen: target instanceof HTMLDetailsElement ? target.open : null,
      targetContainsFocus:
        target instanceof Element && activeElement instanceof Element ? target.contains(activeElement) : false
    };
  }, expectedTargetId);

  ensure(beforeDismiss.bannerVisible, 'Legacy hash flow: cookie banner was not visible on first load.');
  ensure(beforeDismiss.modalLockActive, 'Legacy hash flow: cookie banner did not lock the page shell.');
  ensure(beforeDismiss.activeInBanner, 'Legacy hash flow: initial focus escaped the cookie banner.');
  ensure(
    beforeDismiss.hash === LEGACY_SOURCE_HASH,
    `Legacy hash flow: expected initial hash "${LEGACY_SOURCE_HASH}", got "${beforeDismiss.hash}".`
  );
  ensure(beforeDismiss.targetOpen === false, 'Legacy hash flow: source disclosure opened before consent dismissal.');
  ensure(
    beforeDismiss.targetContainsFocus === false,
    'Legacy hash flow: source disclosure received focus before consent dismissal.'
  );

  await page.getByRole('button', { name: 'Essential only' }).click();
  await page.waitForFunction((targetId) => {
    const target = document.getElementById(targetId);
    const activeElement = document.activeElement;

    return (
      !document.querySelector('.cookie-banner') &&
      document.body.dataset.cookieBannerOpen !== 'true' &&
      window.location.hash === `#${targetId}` &&
      target instanceof HTMLDetailsElement &&
      target.open &&
      activeElement instanceof Element &&
      target.contains(activeElement)
    );
  }, expectedTargetId);

  return expectedTargetId;
}

async function verifyLegacyHashFlowWithStoredConsent(page) {
  await page.goto(`${MARKET_PATH}${LEGACY_SOURCE_HASH}`, { waitUntil: 'load' });
  await page.waitForFunction(() => {
    const thirdSource = document.querySelectorAll('details.source-disclosure').item(2);
    const activeElement = document.activeElement;

    return (
      !document.querySelector('.cookie-banner') &&
      document.body.dataset.cookieBannerOpen !== 'true' &&
      thirdSource instanceof HTMLDetailsElement &&
      window.location.hash === `#${thirdSource.id}` &&
      thirdSource.open &&
      activeElement instanceof Element &&
      thirdSource.contains(activeElement)
    );
  });

  const afterLoad = await page.evaluate(() => {
    const thirdSource = document.querySelectorAll('details.source-disclosure').item(2);
    const activeElement = document.activeElement;

    return {
      bannerVisible: !!document.querySelector('.cookie-banner'),
      hash: window.location.hash,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      targetContainsFocus:
        thirdSource instanceof Element && activeElement instanceof Element
          ? thirdSource.contains(activeElement)
          : false,
      targetId: thirdSource instanceof HTMLDetailsElement ? thirdSource.id : null,
      targetOpen: thirdSource instanceof HTMLDetailsElement ? thirdSource.open : null
    };
  });

  ensure(afterLoad.targetId, 'Stored-consent legacy hash flow: could not resolve the third market source disclosure id.');
  ensure(afterLoad.bannerVisible === false, 'Stored-consent legacy hash flow: cookie banner was still visible.');
  ensure(
    afterLoad.modalLockActive === false,
    'Stored-consent legacy hash flow: cookie banner lock was still active.'
  );
  ensure(
    afterLoad.hash === `#${afterLoad.targetId}`,
    `Stored-consent legacy hash flow: expected canonical hash "#${afterLoad.targetId}", got "${afterLoad.hash}".`
  );
  ensure(afterLoad.targetOpen === true, 'Stored-consent legacy hash flow: source disclosure did not open.');
  ensure(
    afterLoad.targetContainsFocus,
    'Stored-consent legacy hash flow: focus did not land inside the canonical source disclosure.'
  );

  return afterLoad.targetId;
}

async function verifyMalformedHashFlow(page) {
  await page.goto(`${MARKET_PATH}${MALFORMED_SOURCE_HASH}`, { waitUntil: 'load' });
  await page.waitForFunction(() => !!document.querySelector('.cookie-banner'));

  const beforeDismiss = await page.evaluate(() => {
    const activeElement = document.activeElement;

    return {
      activeInBanner:
        activeElement instanceof Element ? !!activeElement.closest('.cookie-banner') : false,
      bannerVisible: !!document.querySelector('.cookie-banner'),
      hash: window.location.hash,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      openDisclosureCount: document.querySelectorAll('details.source-disclosure[open]').length
    };
  });

  ensure(beforeDismiss.bannerVisible, 'Malformed hash flow: cookie banner was not visible on first load.');
  ensure(beforeDismiss.modalLockActive, 'Malformed hash flow: cookie banner did not lock the page shell.');
  ensure(beforeDismiss.activeInBanner, 'Malformed hash flow: initial focus escaped the cookie banner.');
  ensure(
    beforeDismiss.hash === MALFORMED_SOURCE_HASH,
    `Malformed hash flow: expected initial hash "${MALFORMED_SOURCE_HASH}", got "${beforeDismiss.hash}".`
  );
  ensure(
    beforeDismiss.openDisclosureCount === 0,
    'Malformed hash flow: a source disclosure opened before consent dismissal.'
  );

  await page.getByRole('button', { name: 'Essential only' }).click();
  await page.waitForFunction(() => !document.querySelector('.cookie-banner'));

  const afterDismiss = await page.evaluate(() => {
    const activeElement = document.activeElement;
    const mainContent = document.getElementById('main-content');
    const activeDisclosure = activeElement instanceof Element ? activeElement.closest('details.source-disclosure') : null;

    return {
      activeDisclosureId: activeDisclosure instanceof HTMLDetailsElement ? activeDisclosure.id : null,
      hash: window.location.hash,
      mainContentFocused: activeElement === mainContent,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      openDisclosureCount: document.querySelectorAll('details.source-disclosure[open]').length
    };
  });

  ensure(
    afterDismiss.hash === MALFORMED_SOURCE_HASH,
    `Malformed hash flow: expected malformed hash to remain "${MALFORMED_SOURCE_HASH}", got "${afterDismiss.hash}".`
  );
  ensure(afterDismiss.modalLockActive === false, 'Malformed hash flow: cookie banner lock remained active after dismissal.');
  ensure(
    afterDismiss.openDisclosureCount === 0,
    'Malformed hash flow: a source disclosure opened after consent dismissal.'
  );
  ensure(
    afterDismiss.activeDisclosureId === null,
    `Malformed hash flow: focus landed inside source disclosure "${afterDismiss.activeDisclosureId}".`
  );
  ensure(
    afterDismiss.mainContentFocused,
    'Malformed hash flow: focus did not return to the main content after dismissing the banner.'
  );
}

async function main() {
  const firstArgument = process.argv[2];

  if (firstArgument === '--help' || firstArgument === '-h') {
    printUsage();
    return;
  }

  const baseUrl = getBaseUrl(firstArgument);
  const playwright = await loadPlaywright();
  const browserType = getBrowserType(playwright, DEFAULT_BROWSER);

  await withFreshPage(browserType, baseUrl, verifyStableHashFlow);
  console.log(`PASS stable hash deferred correctly: #${STABLE_SOURCE_TARGET_ID}`);

  const expectedLegacyTargetId = await withFreshPage(browserType, baseUrl, verifyLegacyHashFlow);
  console.log(
    `PASS legacy hash deferred and canonicalized correctly: ${LEGACY_SOURCE_HASH} -> #${expectedLegacyTargetId}`
  );

  await withFreshPage(browserType, baseUrl, verifyMalformedHashFlow);
  console.log(`PASS malformed hash ignored safely: ${MALFORMED_SOURCE_HASH}`);

  await withFreshPage(browserType, baseUrl, verifyStableHashFlowWithStoredConsent, {
    consent: STORED_CONSENT_VALUE
  });
  console.log(
    `PASS stored ${STORED_CONSENT_VALUE} consent preserves stable source deep link: #${STABLE_SOURCE_TARGET_ID}`
  );

  const storedConsentLegacyTargetId = await withFreshPage(
    browserType,
    baseUrl,
    verifyLegacyHashFlowWithStoredConsent,
    { consent: STORED_CONSENT_VALUE }
  );
  console.log(
    `PASS stored ${STORED_CONSENT_VALUE} consent preserves legacy deep link: ${LEGACY_SOURCE_HASH} -> #${storedConsentLegacyTargetId}`
  );

  console.log(`Verified market source hash flows successfully against ${baseUrl}`);
}

void main().catch((error) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  console.error(message);
  process.exitCode = 1;
});
