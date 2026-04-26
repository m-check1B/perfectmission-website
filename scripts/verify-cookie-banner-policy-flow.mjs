#!/usr/bin/env node

import process from 'node:process';

const DEFAULT_BASE_URL = 'http://127.0.0.1:4175/';
const DEFAULT_BROWSER = process.env.PLAYWRIGHT_BROWSER ?? 'chromium';
const CONSENT_KEY = 'perfectmission_cookie_consent';
const HOME_PATH = '/';
const POLICY_PATH = '/privacy/';

function printUsage() {
  console.log(`Usage: node scripts/verify-cookie-banner-policy-flow.mjs [base-url]

Runs a fresh-consent browser verification and asserts:
- the cookie banner starts modal on product routes and locks the page shell
- the Privacy Policy link navigates to /privacy/ while keeping the banner visible
- the legal page restores page-shell interactivity and removes the modal backdrop
- dismissing the banner on /privacy/ stores the selected consent and focuses main content

Examples:
  npm run verify:cookie-banner-policy-flow
  npm run verify:cookie-banner-policy-flow -- http://127.0.0.1:4175/
  PLAYWRIGHT_BROWSER=webkit npm run verify:cookie-banner-policy-flow
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
      `Playwright could not be loaded. Run this script via \`npm run verify:cookie-banner-policy-flow\` or install Playwright first.\n${message}`
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

async function withFreshPage(browserType, baseUrl, run) {
  let browser;
  let context;

  try {
    browser = await browserType.launch({ headless: true });
    context = await browser.newContext({ baseURL: baseUrl });
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

async function readBannerState(page) {
  return page.evaluate((consentKey) => {
    const activeElement = document.activeElement;
    const banner = document.querySelector('.cookie-banner');
    const mainContent = document.getElementById('main-content');
    const pageShell = document.querySelector('.page-shell');

    return {
      activeInBanner:
        activeElement instanceof Element ? !!activeElement.closest('.cookie-banner') : false,
      bannerVisible: !!banner,
      backdropVisible: !!document.querySelector('.cookie-banner-backdrop'),
      consentValue: window.localStorage.getItem(consentKey),
      mainContentFocused: activeElement === mainContent,
      modalLockActive: document.body.dataset.cookieBannerOpen === 'true',
      pageShellAriaHidden: pageShell instanceof HTMLElement ? pageShell.getAttribute('aria-hidden') : null,
      pageShellInert: pageShell instanceof HTMLElement ? pageShell.inert : null,
      path: window.location.pathname,
      policyHeadingVisible: !!document.querySelector('main h1')?.textContent?.includes('Privacy Policy'),
      bannerAriaModal:
        banner instanceof HTMLElement ? banner.getAttribute('aria-modal') : null
    };
  }, CONSENT_KEY);
}

async function verifyPolicyConsentChoice(page, buttonLabel, expectedConsent) {
  await page.goto(HOME_PATH, { waitUntil: 'load' });
  await page.waitForFunction(() => !!document.querySelector('.cookie-banner'));

  const initialState = await readBannerState(page);
  ensure(initialState.path === HOME_PATH, `Expected initial path "${HOME_PATH}", got "${initialState.path}".`);
  ensure(initialState.bannerVisible, 'Initial product-route state: cookie banner was not visible.');
  ensure(initialState.backdropVisible, 'Initial product-route state: cookie banner backdrop was not visible.');
  ensure(initialState.bannerAriaModal === 'true', 'Initial product-route state: cookie banner was not modal.');
  ensure(initialState.modalLockActive, 'Initial product-route state: cookie banner lock was not active.');
  ensure(initialState.pageShellInert === true, 'Initial product-route state: page shell was not inert.');
  ensure(
    initialState.pageShellAriaHidden === 'true',
    'Initial product-route state: page shell was not hidden from assistive tech.'
  );
  ensure(initialState.activeInBanner, 'Initial product-route state: focus escaped the cookie banner.');

  await Promise.all([
    page.waitForURL((url) => url.pathname === POLICY_PATH),
    page.getByRole('link', { name: 'Privacy Policy' }).click()
  ]);
  await page.waitForFunction(() => {
    const banner = document.querySelector('.cookie-banner');
    const mainContent = document.getElementById('main-content');
    const pageShell = document.querySelector('.page-shell');

    return (
      window.location.pathname === '/privacy/' &&
      !!banner &&
      !document.querySelector('.cookie-banner-backdrop') &&
      document.body.dataset.cookieBannerOpen !== 'true' &&
      pageShell instanceof HTMLElement &&
      !pageShell.inert &&
      pageShell.getAttribute('aria-hidden') !== 'true' &&
      mainContent instanceof HTMLElement &&
      document.activeElement === mainContent
    );
  });

  const policyState = await readBannerState(page);
  ensure(policyState.path === POLICY_PATH, `Expected policy path "${POLICY_PATH}", got "${policyState.path}".`);
  ensure(policyState.bannerVisible, 'Policy-route state: cookie banner disappeared before consent choice.');
  ensure(policyState.backdropVisible === false, 'Policy-route state: banner backdrop was still visible.');
  ensure(policyState.bannerAriaModal === null, 'Policy-route state: banner was still exposed as modal.');
  ensure(policyState.modalLockActive === false, 'Policy-route state: cookie banner lock was still active.');
  ensure(policyState.pageShellInert === false, 'Policy-route state: page shell was still inert.');
  ensure(
    policyState.pageShellAriaHidden !== 'true',
    'Policy-route state: page shell was still hidden from assistive tech.'
  );
  ensure(policyState.mainContentFocused, 'Policy-route state: main content did not regain focus.');
  ensure(policyState.policyHeadingVisible, 'Policy-route state: Privacy Policy content did not render.');

  await page.getByRole('button', { name: buttonLabel }).click();
  await page.waitForFunction(
    ({ consentKey, expectedValue }) => {
      const mainContent = document.getElementById('main-content');
      const pageShell = document.querySelector('.page-shell');

      return (
        !document.querySelector('.cookie-banner') &&
        !document.querySelector('.cookie-banner-backdrop') &&
        document.body.dataset.cookieBannerOpen !== 'true' &&
        window.location.pathname === '/privacy/' &&
        window.localStorage.getItem(consentKey) === expectedValue &&
        pageShell instanceof HTMLElement &&
        !pageShell.inert &&
        pageShell.getAttribute('aria-hidden') !== 'true' &&
        mainContent instanceof HTMLElement &&
        document.activeElement === mainContent
      );
    },
    { consentKey: CONSENT_KEY, expectedValue: expectedConsent }
  );

  const closedState = await readBannerState(page);
  ensure(closedState.bannerVisible === false, `After "${buttonLabel}": cookie banner was still visible.`);
  ensure(closedState.modalLockActive === false, `After "${buttonLabel}": cookie banner lock was still active.`);
  ensure(closedState.pageShellInert === false, `After "${buttonLabel}": page shell was still inert.`);
  ensure(
    closedState.pageShellAriaHidden !== 'true',
    `After "${buttonLabel}": page shell was still hidden from assistive tech.`
  );
  ensure(closedState.mainContentFocused, `After "${buttonLabel}": focus did not land on main content.`);
  ensure(
    closedState.consentValue === expectedConsent,
    `After "${buttonLabel}": expected consent "${expectedConsent}", got "${closedState.consentValue}".`
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

  await withFreshPage(browserType, baseUrl, (page) =>
    verifyPolicyConsentChoice(page, 'Essential only', 'essential')
  );
  console.log('PASS Privacy Policy flow keeps the banner non-modal and stores essential-only consent');

  await withFreshPage(browserType, baseUrl, (page) =>
    verifyPolicyConsentChoice(page, 'Accept analytics', 'all')
  );
  console.log('PASS Privacy Policy flow keeps the banner non-modal and stores analytics consent');

  console.log(`Verified cookie-banner policy flow successfully against ${baseUrl}`);
}

void main().catch((error) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  console.error(message);
  process.exitCode = 1;
});
