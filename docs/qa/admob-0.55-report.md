# AdMob placements — 0.55.0 / code57

User confirmed official Google test ads because production IDs are not available. Implemented adaptive management-page banners, preloaded natural-break interstitials, optional food/queue rewards, delivery pacing, local diagnostics and safe callback handling. Full placement rules and production boundaries are in ../monetization-boundary.md.

## Verification

- 33 focused ad checks passed: official-ID gate, first-session grace, fullscreen cooldown, session/day caps, reward caps, clock rollback, millisecond persistence, banner context, no-fill, duplicate/late/stale callbacks, valid save receipts, resume dictionary replacement, active assistance renewal, skipped/eligible natural breaks, show failure, retry backoff, stale loader callback and expired cache rejection.
- 83 essential gameplay/save checks passed. No broad campaign replay.
- Real pointer phone harness passed Stronghold entry, desktop no-fill, simulated earned food, simulated four-hour assistance reward, enabling the selected hunt and Journey preparation link. Six phone captures reviewed, including 130% text. Actual rendered surfaces 412×824 and360×720; scrollable content remains above fixed footer actions.
- Native callbacks were simulated in the harness. No connected Android device: Google serving, actual adaptive banner dimensions/position, native fullscreen lifecycle and native sound remain unverified. The APK is a test delivery, not proof of native ad serving.
- Focused test and UI harness retain the pre-existing shutdown warning of11 ObjectDB instances/five resources. Initial callback reference cycles were removed with weak references; no script assertion/runtime failure in the final checks.
- No live IDs, ad account changes, billing integration, remote telemetry, publishing or push. Save package identity preserved.

## Package

Android debug **0.55.0 / code57**, package `com.ashencovenant.prototype`, arm64-v8a/x86_64. APK: `build/android/cinder-dominion-0.55.0.apk`, **315,868,079 bytes**. Signature Scheme v2 verified. Manifest confirms official Google demo App ID and native banner/interstitial/rewarded plugins. Archive contains the new policy/provider/reward UI and correct demo unit configuration.

SHA256: `0B6B5CFAEC8A43C2DD1A11B0613BF7A13BFB0169D0ED3F4E1644CE8064F50E4A`.

Exporter reached `[DONE] export`; the child exited. The remaining identified console wrapper was stopped after package verification, not reported as a natural exit-zero.
