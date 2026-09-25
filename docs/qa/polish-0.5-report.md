# Polish 0.5 — focused verification

Solo implementation with limited checks, following the user's request to reserve extended playtesting for them.

- 26 domain assertions passed, including the prior 22 and four new checks: distinct guardian attacks, improved predicted expedition fragment yield, displayed-versus-applied relic food healing, and Oracle healing consistency between offline catch-up and one-second steps.
- Godot 4.7.1 imported the new guardian art and scripts.
- Seven phone-sized screens were captured: opening order, crafting plan, work orders, hunting grounds, Oracle preparation, Oracle combat, and a crafting plan with 130% text.
- The actual opening dialog's pinned button was activated by the capture script, and the queued task produced four copper ore. The Oracle dialog's pinned action also started combat.
- Visual review found and corrected a cropped guardian face, plural wording, obscured combat labels and unclear quick-start behavior. Preparation now shows risk and the signature attack before the rewards. Recent simultaneous damage/healing remains visible.
- Large-text inspection confirmed the primary crafting action stays visible while the explanation scrolls.
- This is a desktop-rendered portrait viewport, not an Android physical-device validation. No long balance run, emulator matrix or retention experiment was performed.

Screenshots are under `docs/qa/screenshots/` with the `-0.5.png` suffix.

Android debug export completed successfully, including APK verification, with version code 5 / version name 0.5.0. Package: `build/android/ashen-covenant-0.5.apk` (73,603,065 bytes). SHA-256: `A7C9CCE42E0941194C61F5DA1429A29840FECEB91F31C2EDDFE6A0FB0C9F766E`. Export log: `build/export-0.5.log`. This is a debug-signed playtest build, not a store release.
