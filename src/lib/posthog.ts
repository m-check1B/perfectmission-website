import { browser } from '$app/environment';

const POSTHOG_TOKEN = import.meta.env.VITE_POSTHOG_API_KEY || 'phc_7046iNH3W5qKp0CDbMYpPpwgi71Z7HsMo7GBkKRFbEg';
const POSTHOG_HOST = import.meta.env.VITE_POSTHOG_HOST || 'https://eu.i.posthog.com';
const CONSENT_KEY = 'perfectmission_cookie_consent';

let initialized = false;
let initPromise: Promise<void> | null = null;
let sessionConsent: 'essential' | 'all' | null = null;

function readConsent(): string | null {
  try {
    return localStorage.getItem(CONSENT_KEY) ?? sessionConsent;
  } catch {
    return sessionConsent;
  }
}

function privacySignalBlocksAnalytics(): boolean {
  if (!browser) return true;
  const navigatorWithGpc = navigator as Navigator & { globalPrivacyControl?: boolean };
  return navigatorWithGpc.globalPrivacyControl === true || navigator.doNotTrack === '1';
}

export function hasConsent(): boolean {
  if (!browser) return false;
  return readConsent() === 'all';
}

export function setConsent(level: 'essential' | 'all'): void {
  if (!browser) return;
  sessionConsent = level;
  try {
    localStorage.setItem(CONSENT_KEY, level);
  } catch {
    // Ignore storage failures so consent choices do not break the UI flow.
  }
}

export function needsConsentBanner(): boolean {
  if (!browser) return false;
  return readConsent() === null;
}

export async function initPostHog(site: string): Promise<void> {
  if (!browser || initialized || initPromise) return initPromise ?? Promise.resolve();
  if (!hasConsent() || privacySignalBlocksAnalytics()) return;

  initPromise = import('posthog-js')
    .then(({ default: posthog }) => {
      posthog.init(POSTHOG_TOKEN, {
        api_host: POSTHOG_HOST,
        defaults: '2026-01-30',
        person_profiles: 'identified_only',
        capture_pageview: 'history_change',
        capture_pageleave: true,
        cross_subdomain_cookie: false,
        disable_external_dependency_loading: true,
        enable_recording_console_log: false,
        before_send: (event) => {
          const hostname = window.location.hostname;

          if (hostname === '127.0.0.1' || hostname === 'localhost') {
            return null;
          }

          return event;
        },
        loaded: (instance) => {
          instance.register({ site });
          window.posthog = instance as typeof window.posthog;
        },
        session_recording: {
          maskAllInputs: false,
          maskInputFn: (text, element) => {
            if (
              (element as HTMLInputElement)?.type === 'password' ||
              (element as HTMLInputElement)?.type === 'email' ||
              (element as HTMLInputElement)?.type === 'tel'
            ) {
              return '*'.repeat(text.length);
            }

            return text;
          }
        }
      });

      initialized = true;
    })
    .finally(() => {
      initPromise = null;
    });

  return initPromise;
}

export function captureEvent(event: string, properties?: Record<string, unknown>): boolean {
  if (!browser || !hasConsent() || !window.posthog) return false;
  window.posthog.capture(event, properties);
  return true;
}
