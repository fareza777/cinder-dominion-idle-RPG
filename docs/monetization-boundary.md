# AdMob test integration and future purchases — 0.32

Android uses Poing Studios Godot AdMob plugin v5.1.0 (MIT), vendored with Android ads/core AARs. Source: https://github.com/poingstudios/godot-admob-plugin/releases/tag/v5.1.0. Matching android-template-v4.7.1.zip supplies binaries. Exporter declares Google ads-mobile-sdk 1.4.0. One vendor patch makes installation honor disabled iOS instead of downloading it.

Project settings and data/ads.json use Google demo application and banner/interstitial/rewarded IDs. services/admob.gd initializes on request, handles failure/timeout, reserves banner space, blocks full-screen requests in combat/onboarding, and imposes a 15-minute interstitial cooldown per session. Settings exposes test buttons; no automatic ads are inserted into gameplay.

Rewarded tests grant five selected meals only on the SDK earned-reward callback, once per ad and only to the same journey. Closing/unavailable ads grant nothing. This client callback is not server verification or a tamper-proof economy. No physical Android ad display was tested.

Production remains blocked. Live rollout requires real IDs, appropriate UMP consent/privacy choices, store disclosures, native device tests and reviewed placements. Trusted monetized rewards need server verification and durable duplicate handling. Setting test_mode=false does not enable production.

Purchases remain a disabled seam in services/commerce.gd and data/commerce.json. No billing SDK, purchasable character, published product or entitlement verification exists. All three characters are free. The character registry accepts future definitions; paid access additionally requires billing, receipt verification, restore and entitlement handling.

## Rebuilding Android

Use Godot 4.7.1 matching export templates, Java 17 and Android SDK. Install Godot Android build template into the project (android/build is generated and ignored), retaining android/.build_version. The enabled AdMob exporter applies Gradle dependencies. Export Android with Gradle enabled. Native AARs under addons/admob/android/bin/ads are tracked; keystores and machine paths are not. First export requires network access for Gradle/Maven. No paid service was connected.
