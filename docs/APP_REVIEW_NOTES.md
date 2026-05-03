# Notes for the App Review Team

Thank you for reviewing Hush.

## What Hush does

Hush is a privacy-focused web viewer. The user adds websites they want to visit; each site opens in a fully isolated WKWebView session with the following protections applied:

- Non-persistent WKWebsiteDataStore per session (cookies, cache, localStorage, IndexedDB are wiped when the tab closes)
- WKContentRuleList that blocks ~250 well-known tracker, ad-network, and analytics domains
- WKUserScript injected at document start that masks Canvas, WebGL, AudioContext, Battery, Network Information, and other fingerprinting APIs
- Apple's `isFraudulentWebsiteWarningEnabled` is on
- File downloads are blocked (`canShowMIMEType` check) — user is shown an alert
- Tracking URL parameters (utm_*, fbclid, gclid, msclkid, etc.) are stripped before navigation
- Disallowed schemes (file://, ftp://, javascript:, etc.) are rejected
- Clipboard read APIs are no-op'd

## What Hush does **not** do

- No VPN, no proxy. We make this clear in the app's About section and the App Store description. Hush does **not** claim to hide the user's IP address.
- No data collection of any kind. Hush has no backend, no analytics, no third-party SDKs.
- No accounts, no signup, no login.

## How to test

1. Tap "Get started" through the 3-screen onboarding.
2. On the Sites tab, tap the `+` icon and add any website (e.g., `reddit.com`, `news.ycombinator.com`, `wikipedia.org`).
3. Tap the new row to open the site in fullscreen.
4. In the bottom toolbar:
   - 📄 icon → Reader Mode (strips scripts, shows a clean view)
   - 🔒 icon → Site Info sheet (HTTPS status, TLS certificate, server IP)
   - ⋯ icon → menu with "Clear session"
5. Pull down or tap the X to dismiss the browser.
6. Visit the Privacy tab to see aggregated stats per site.
7. Visit the Settings tab to see protection toggles.

## Why this is not Guideline 4.2 (Minimum Functionality)

Hush is not a thin web wrapper. It implements a substantial privacy layer on top of WKWebView that is not available in mobile Safari, including:

- Per-site session isolation (Safari uses one shared cookie store)
- Aggressive tracker blocking at the network layer
- JavaScript-injection-based fingerprint masking (Canvas, WebGL, Audio, Battery, etc.)
- Automatic stripping of tracking parameters from URLs (utm_*, fbclid, gclid, etc.)
- Built-in download blocking with explicit user notification
- A privacy dashboard that surfaces what was blocked
- A Reader Mode tailored for safety (strips all scripts before rendering)
- A transparent Site Info panel showing TLS and certificate details
- A first-launch onboarding that explains the privacy model

These are user-visible features that justify a standalone app distinct from Safari.

## WebKit / Browser Engine

Hush uses Apple's WKWebView exclusively. No alternative browser engine is used.

## Accessibility

Hush uses native SwiftUI throughout, supports Dynamic Type via system fonts, and respects Dark Mode.

## Contact during review

If you have any questions:
salih.kokesmer@uzser.com.tr
