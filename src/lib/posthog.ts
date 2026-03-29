import posthog from 'posthog-js';
import { browser } from '$app/environment';

const POSTHOG_TOKEN = 'phc_7046iNH3W5qKp0CDbMYpPpwgi71Z7HsMo7GBkKRFbEg';
const POSTHOG_HOST = 'https://eu.i.posthog.com';
const CONSENT_KEY = 'perfectmission_cookie_consent';

let initialized = false;

export function hasConsent(): boolean {
  if (!browser) return false;
  try {
    return localStorage.getItem(CONSENT_KEY) === 'all';
  } catch {
    return false;
  }
}

export function setConsent(level: 'essential' | 'all'): void {
  if (!browser) return;
  localStorage.setItem(CONSENT_KEY, level);
}

export function needsConsentBanner(): boolean {
  if (!browser) return false;
  try {
    return localStorage.getItem(CONSENT_KEY) === null;
  } catch {
    return true;
  }
}

export function initPostHog(site: string) {
  if (!browser || initialized) return;
  if (!hasConsent()) return;

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
}
