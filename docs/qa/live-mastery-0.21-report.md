# Build 0.21 verification

- Existing 77 essential checks passed. No economy or save code changed.
- Focused UI script completed with no errors: an actual queued victory crossed 24 to 25 wins while the same detail dialog remained open; rewards changed to 2 fragments and the live action changed from 1 to 50 fights. Pressing that action queued 50 fights through the activity confirmation.
- Collection counters and final 149-to-150 rank refresh exercised with controlled fixtures. Dismissal cleared modal callbacks.
- Five phone captures reviewed: before rank-up, live rank-up, collection, maximum mastery (480x960), and narrow layout at 130% text (360x800). Scrollable content and fixed hunt action remained readable.
- Initial import found an extra closing parenthesis introduced during editing; corrected. Final import and capture logs contain no errors. Capture rerun removed an unrelated task toast from screenshots.
- Android debug export signed and verified by Godot. APK package com.ashencovenant.prototype, versionCode 21, versionName 0.21.0; arm64-v8a and x86_64.

APK: build/android/ashen-covenant-0.21.apk
SHA256: B2A7D9EDFFC76198465D54ABEE7BD69FE9F9CC3912DC93914380A0DD7E0453BF

No physical Android installation, long-duration balance playtest or direct Realm Idle playtest. Collection ordering and newly available enemy membership refresh only when reopened; live counters do not reorder cards. Existing saves are untouched by preview captures. This is a focused usability iteration, not a release-quality certification.
