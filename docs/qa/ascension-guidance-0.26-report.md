# Build 0.26 verification

## Change
Ascension now offers a state-dependent primary action: inspect current queue, train the next missing skill, plan a sword, inspect and equip an owned upgrade, refine an underpowered owned sword, or continue Journey/review unlocked Apex hunts. Clicking recalculates the current action. An already equipped stronger weapon skips redundant lower-tier sword preparation. Skill levels, training visibility and owned counts update without reopening the panel. Browse Apex hunts remains available separately.

## Actual verification
- Godot editor import completed without script errors.
- All 83 existing essential checks passed once.
- Capture26 exercised live Mining-to-Woodcutting guidance, all prerequisites becoming ready, real material-plan and queue button signals, completed crafting, item inspection and equip, Journey versus unlocked Apex navigation, and retaining stronger equipped gear.
- Five runtime screenshots inspected: training, craft-ready, current work, equip-ready and narrow Dawn tier. Standard viewport 480x960; narrow 360x800 with 130% text. Fixed footer remains reachable; long body scrolls. The craft-ready image includes the normal temporary level-up toast.
- Capture error log empty. git diff --check passed.
- Godot signed and verified the Android debug APK. aapt confirms com.ashencovenant.prototype, versionCode 26, versionName 0.26.0, arm64-v8a and x86_64.

APK: build/android/ashen-covenant-0.26.apk

Bytes: 91872194

SHA256: 12C0EFEC45EE523D588B2348429357516654D1F30D2456E93F6AC6386BB228E3

## Limitations
No physical Android install or natural long-session playtest. The guidance uses a common tier sword attack threshold; it does not certify whole-build readiness for an Apex fight. Hunt planning still evaluates the actual build. No new art/audio or economy/save-format changes. Preview fixtures do not write user saves. Refinement dispatch is implemented but not exercised by the capture walkthrough. Existing 0.25 balance and audio-listening limitations remain.
