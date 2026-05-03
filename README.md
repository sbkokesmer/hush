# Hush

> A safer way to visit websites you don't fully trust.

Hush is an iOS app that opens any website you add in a fully isolated session. Trackers, ads, and browser fingerprinting are blocked. Cookies and cache are wiped when you close a tab. No accounts, no servers, no telemetry — everything stays on your device.

## Features

- Per-site isolated `WKWebView` sessions (cookies wiped on close)
- ~250 tracker / ad-network / analytics domains blocked at the network layer
- Browser-fingerprinting masking (Canvas, WebGL, Audio, Battery, Network)
- WebRTC disabled (no IP leak)
- Tracking-parameter stripping (`utm_*`, `fbclid`, `gclid`, `msclkid`, ...)
- Apple Safe Browsing (fraudulent-website warning) on
- File downloads blocked by default
- Clipboard read APIs no-op'd
- Reader Mode (script-free, dark themed)
- Site Info panel (HTTPS, certificate, server IP)
- App Switcher privacy overlay

## Build

Requires Xcode 26+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
cd hush
xcodegen generate
open Hush.xcodeproj
```

Then ⌘R to build & run on a simulator or device.

## Project layout

```
hush/
├── project.yml                    # XcodeGen config
├── scripts/                       # Icon generators
└── Hush/
    ├── HushApp.swift              # @main + privacy overlay
    ├── Models/                    # SwiftData models
    ├── Services/                  # PrivacyWebView, ContentBlocker, FingerprintProtection,
    │                              # ReaderMode, SiteInfo, LinkSanitizer
    ├── Views/                     # SwiftUI screens
    └── Resources/
        ├── Info.plist
        ├── blocker-rules.json     # Tracker block rules (WKContentRuleList format)
        └── Assets.xcassets/
```

## Privacy

Hush collects nothing. See [docs/PRIVACY.md](docs/PRIVACY.md).

## License

All rights reserved. Source published for transparency. Contact the developer for permission to reuse.

## Author

Salih Kökeşmer · salih.kokesmer@uzser.com.tr
