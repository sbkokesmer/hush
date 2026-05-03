---
title: PRIVACY
---

# Privacy Policy

**Effective date:** May 3, 2026
**App:** Hush — Safe Way to Visit Websites
**Developer:** Salih Kökeşmer

## Summary

Hush does not collect, store, transmit, or sell any personal data. Everything you do in the app stays on your device. We have no servers, no analytics, no advertising, and no third-party SDKs that observe you.

## What Hush is NOT

To set correct expectations and avoid confusion:

- **Hush is NOT a VPN.** Hush does not change, hide, or proxy your IP address. The websites you visit through Hush still see your real IP address and approximate geographic location, exactly as they would in any other browser.
- **Hush does NOT hide your country, city, or ISP.** Geo-location based on your IP is visible to sites you visit.
- **Hush is NOT an antivirus or malware scanner.** It blocks file downloads by default and warns about known phishing sites (using Apple's built-in Safe Browsing), but it cannot guarantee protection against every threat.
- **Hush does NOT make you anonymous.** If you sign in to a website through Hush, that website knows it is you. Your account, your session.
- **Hush is NOT a Tor browser.** No onion routing, no traffic mixing.

What Hush *does* do is reduce the amount of data that trackers, advertisers, and fingerprinting scripts can collect about you while you browse — entirely on your device, with no server in the middle.

## What we don't collect

We do not collect:

- Your name, email address, phone number, or any account information
- Your IP address
- The websites you add to Hush
- The websites you visit through Hush
- Your browsing history, cookies, cache, or local storage
- Crash reports or analytics events
- Device identifiers (IDFA, IDFV, advertising IDs)
- Location data
- Contact information
- Photos, files, or any other content from your device

## What stays on your device

The following data is stored only on your device using Apple's SwiftData (a local database). It is never transmitted off your device:

- The list of sites you have added
- Each site's name, URL, and visit history
- Visit duration and tracker-block counts (used for the in-app statistics screen)
- Your in-app settings (toggles for tracker blocking, fingerprint protection, etc.)

You can delete this data at any time by removing a site from the list, or by uninstalling the app.

## Network requests

Hush makes network requests in two situations only:

1. **When you visit a website you added.** The request goes directly from your device to the website you chose, using Apple's WKWebView. Hush does not proxy, log, or modify the destination of your traffic.
2. **When loading a favicon for your site list.** Favicons are fetched from `google.com/s2/favicons` so your site list shows recognisable icons. This request reveals only the domain name of the site whose icon is being fetched. We do not control or log this request — it is a direct call from your device to Google's favicon service. If you prefer not to use this, we will offer an opt-out in a future version.

We do not operate any servers. No request goes to any Hush-controlled infrastructure, because none exists.

## Third-party services

Hush does not embed any third-party SDKs (no Firebase, no Google Analytics, no Facebook SDK, no advertising frameworks, no crash reporters).

The only third-party service contacted by the app is Google's favicon service, described above.

## How Hush protects you

Hush uses Apple's WebKit (`WKWebView`) and applies the following protections to every site you visit through the app:

- Each site opens in an isolated, non-persistent session (`WKWebsiteDataStore.nonPersistent()`)
- Cookies, cache, localStorage, IndexedDB, and ServiceWorkers are wiped when you close a tab
- Known tracker and ad-network domains are blocked at the network layer
- Browser fingerprinting APIs (Canvas, WebGL, Audio, Battery, Network Information) are masked
- WebRTC is disabled to prevent IP leaks
- Document referrer is cleared
- HTTP requests are upgraded to HTTPS where possible
- Apple's fraudulent-website warning (Safe Browsing) is enabled
- File downloads are blocked by default
- JavaScript clipboard reads are blocked
- Known tracking parameters (`utm_*`, `fbclid`, `gclid`, etc.) are stripped from URLs

These protections happen entirely on your device.

## Children's privacy

Hush is not directed at children under 13. We do not knowingly collect any data from any user, including children.

## Changes to this policy

If this policy changes, the updated version will be published in the Hush GitHub repository and within an updated app release.

## Contact

If you have questions about this privacy policy, contact:
salih.kokesmer@uzser.com.tr
