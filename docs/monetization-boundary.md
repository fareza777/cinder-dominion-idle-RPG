# AdMob test integration — 0.55

This build uses official Google demo ads only, as requested by the user. No AdMob account or production units are connected, and no ad income is expected. Production and mixed IDs are rejected even if test_mode is changed. Purchases remain disabled; all eight current characters remain free.

## Placements

- Anchored adaptive bottom banner: Stronghold, Skills, Bag and Hero after guidance and 60 active seconds. Hidden in combat, Explore, menus, dialogs, beginner guidance, background and when the keyboard is visible. The measured native height reserves space below navigation with an additional gap. Google controls banner refresh; there is no manual refresh loop.
- Interstitial: only when collecting a completed Journey or choosing Return to Stronghold in the latest completed hunt report (at least three wins). Activity must last at least five minutes. No current work, battle, assistance queue or Journey may be running. Ten active minutes before the first automatic display; at least fifteen minutes after any shown fullscreen ad; maximum three interstitials per session and six per UTC day. The explicit Settings preview bypasses only the initial ten-minute wait. No automatic splash, startup, resume, tab-change, defeat or recall ad.
- Rewarded: explicit choice of 15 selected cooked meals or four hours of queue assistance, each capped at three earned rewards per UTC day, with 90 seconds between rewards. Assistance consumes normal materials/time and must be enabled afterward. Its lease includes offline time. Another lease can be requested only with under thirty minutes remaining. Combat and queued hunts block viewing. Manual gameplay remains available.

The Stronghold provides Optional supplies & assistance; Journey preparation links to that panel. Settings retains clearly labelled test controls and local delivery counters. No remote analytics added.

## Delivery and reward handling

Formats preload independently with 45-second request timeouts, 30–300-second retry backoff and 45-minute fullscreen cache lifetime. A natural break with no ready ad is skipped immediately and recorded, never shown later. Explicit rewarded requests require another tap after loading. Failed/early-closed ads give no reward. Input and game audio are suspended beneath fullscreen ads; game progress is recovered normally on resume without replacing the reward panel with the away report.

Earned callbacks grant once per ad. Optional campaign identity and a bounded receipt list survive normal save/offline dictionary replacement while rejecting callbacks for a new campaign. Pending rewards wait for recovery to finish. Pacing and counters live in user://ad_delivery_v1.json independently of campaign resets and resist wall-clock rollback. These are local/client checks, not server verification, crash-proof transaction storage or a tamper-proof economy.

## Android and production boundary

Vendored Poing Studios Godot AdMob 5.1.0 and its native AARs remain unchanged. Matching Godot 4.7.1 templates, Java17, Android SDK and Gradle export are required. Machine paths and signing keys are not committed. Request content rating is T; no child-directed classification is inferred.

Live rollout still requires real App/unit IDs, appropriate UMP consent/privacy-choice implementation, audience/account configuration, Play disclosures, and native device verification. This preview does not implement a production consent flow. No physical Android device was connected during this iteration: native serving, tap separation, lifecycle callbacks and native sound behavior need on-device verification. No production readiness or revenue optimization claim.

References checked against official Google documentation: [adaptive banners](https://developers.google.com/admob/android/banner), [interstitial transitions](https://developers.google.com/admob/android/interstitial), [rewarded callbacks](https://developers.google.com/admob/android/rewarded), [rewarded opt-in](https://support.google.com/admob/answer/7313578?hl=en-GB). Plugin source: https://github.com/poingstudios/godot-admob-plugin/releases/tag/v5.1.0.
