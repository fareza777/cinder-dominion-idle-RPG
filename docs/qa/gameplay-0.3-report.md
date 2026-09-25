# Gameplay 0.3 — lightweight verification

User requested solo implementation and minimal testing. No agent delegation, broad device matrix, or balance marathon was performed.

- Godot 4.7.1 import and Android debug export completed successfully.
- 17 focused assertions passed: the existing 13 essentials plus supply-plan preview isolation, exact full-chain material accounting, one-time contract/upgrade save validation, and online/offline Warden consistency.
- Desktop screenshots inspected for Explore preparation, live combat, supply planning, fighting styles and refuge upgrades. Capture produced no script errors.
- Android 36 x86_64 emulator: streamed APK installation succeeded, app opened and Settings rendered. No Godot/AndroidRuntime errors were returned in the limited error-log query. Android System UI showed its pre-existing cold-boot ANR/fullscreen prompt and was dismissed; this is not physical-device coverage.
- A final presentation-only fix makes contract progress bars update while their dialog stays open. APK was rebuilt after this fix. The emulator exited before the final reinstall completed, so Android smoke coverage applies to the preceding 0.3 build; the final delta is this progress-bar refresh. No further emulator runs were attempted under the requested light-check policy.

Evidence: `screenshots/combat.png`, `screenshots/explore.png`, `screenshots/supply-planner-0.3.png`, `screenshots/fighting-styles-0.3.png`, `screenshots/contracts-0.3.png`, `screenshots/refuge-upgrades-0.3.png`, and `screenshots/android-menu-0.3.png`.

Remaining for user playtesting: long-run economy and combat balance, device-specific performance/touch behavior, accessibility at every font size, and full Chapter I completion. This is a debug-signed Chapter I preview, not a store release.

Final APK: `build/android/ashen-covenant-0.3.apk`, 69,301,168 bytes. SHA-256: `AE7658E26183D3F9D7D114BBB951BE6A3B8CBF211CEC93CACEF1C0E886C0E372`.
