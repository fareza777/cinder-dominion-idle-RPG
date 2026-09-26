# Build 0.25 verification

## Actual results
- 83 essential checks passed: 77 previous checks with updated item count, plus six checks covering all advanced recipe plans, the level-100 material plan, completed crafting/save round-trip, matching-metal refinement, deterministic Apex combat across time chunks, and a prepared final Apex victory with a one-time contract claim.
- Compared all prior catalog entries against git HEAD before this iteration: every previous item, skill, activity and enemy definition is unchanged. Additive IDs preserve existing progress and saved queues.
- Capture25 used actual UI button signals to open a Dawnsteel sword material plan, queue it, advance crafting, inspect the resulting item and equip it. Nine phone images cover available recipe filtering, locked/unlocked tiers, supply plan, item detail, Apex lists, battle art, and narrow 360x800 at 130% text.
- First capture completed but logged missing-metadata warnings from its recursive test lookup. Added a has_meta guard and reran; final capture completed with an empty error log. Queue/equip toast was hidden in the preview fixture for unobstructed screenshots.
- Original art inspected as generated sheets and as runtime tiles. Three atlases contain 29 paintings. Export archive inspected: all three atlas resources are packaged.
- Final import/capture had no script errors; git diff --check passed.
- APK signed and verified by Godot; aapt reports com.ashencovenant.prototype, versionCode 25, versionName 0.25.0, arm64-v8a and x86_64.

APK: build/android/ashen-covenant-0.25.apk
Bytes: 91872194
SHA256: 858175F711C409EE8935A02FAEEF13CA58A73DA9F95E2147187C41DBF7292D0A

## Limits
No natural-play progression timing run to level 100, full nine-encounter balance sweep, physical Android install/performance test or audio listening test. The final boss check uses a prepared level-100 build and supplies, proving that route is executable, not that every build is viable. No user save files were touched by fixtures. New gear changes high-level economy and power; old content definitions are preserved. Armor/tool/food art is reused where stated. This is a substantive expansion, not a completed SSS-quality claim.
