# Cinder Dominion — release preparation 0.56.0

Date: 2026-10-05

## Delivered

- Public app identity is now **Cinder Dominion: Idle RPG** while the existing package `com.ashencovenant.prototype` remains unchanged for save and Android continuity.
- Product contract `remove_ads` is defined as a non-consumable entitlement at USD 4.99. Settings exposes a clear Store surface and the ad layer respects a verified `entitlements.remove_ads` flag.
- English privacy policy is available in `privacy-policy.html`; `app-ads.txt` is present with the official Google test publisher line until the live AdMob publisher line is known.
- Store copy, metadata, asset mapping and release boundary are documented in `docs/store-listing-2026-10-05.md`.
- Release AAB: `build/android/cinder-dominion-0.56.0.aab`, version code 59, version name 0.56.0, package `com.ashencovenant.prototype`.

## Verification performed

- Godot 4.7.1 headless project scan completed.
- Android Gradle release bundle completed with the existing AdMob and banner-safe plugins.
- Merged release manifest reports package, version code/name, portrait orientation and AdMob application metadata.
- AAB contains a valid release signature. Upload certificate SHA-256: `27:8F:59:DD:1D:E9:0C:AF:6E:45:A3:92:38:46:7F:5C:F9:8E:6B:82:0A:1B:F2:2C:38:F1:1A:28:61:A3:25:52`.
- The Android release build is about 194 MiB and includes the current English UI and export metadata.

## Boundary before public rollout

Play Billing still needs a production adapter and a verified purchase/restore flow; the Store surface deliberately says that checkout is not active in this preview. AdMob still uses official Google test IDs. Replace the test `app-ads.txt` publisher line and use live AdMob units only after consent, privacy choices and physical-device checks. The generated upload keystore is local under `build/signing/` and is ignored by Git; preserve it for future updates or replace it with the publisher's managed upload key.
