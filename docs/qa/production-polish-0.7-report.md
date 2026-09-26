# 0.7 — focused verification and visual review

40 essential assertions passed. The eight additions cover:

- No partial resource spend on blocked refinement.
- One-copy stack splitting, exact/idempotent costs and protected reference updates.
- Merging into an existing higher-quality stack without changing total item count.
- Restoring a complete build, protecting its gear and preserving it through save encoding/decoding.
- Rejecting loadout changes during combat without partial application.
- Exact hunt rewards with matching results for one large offline step and one-second steps.
- Separate recalled and defeated outcomes, including zero HP at defeat.
- Rejecting malformed saved loadout references and negative hunt accounting.

The existing 32 assertions still cover gathering/crafting transactions, saves, guides, progression, work orders, talents, relics, guardian mechanics, runes and offline behavior. Legacy-save verification removes both optional new modules.

## UI and audio integration

Ten 480×960 captures cover the main menu, fresh refuge, returning refuge, workshop, complete loadouts, Sanctum battle, successful hunt report, defeat report, reduced-motion Crown battle and 130% text workshop. The real workshop action was pressed; the equipped Rare Iron Sword became Epic with exactly 360 gold, 12 ingots and 15 scraps deducted.

Visual inspection prompted further refinements: costs precede detail, one-copy wording is natural, ingot planning is hidden when stocked, reports use correct singular forms, loadouts name their talent allocation and show available food, and defeat text uses the warning color. The home artwork is visible below the current objective rather than buried behind system buttons.

A silent audio integration check used the production audio-director component and verified hearth-to-forest transition, the mute preference and background pausing. All generated WAVs were read successfully: four 32-second ambient tracks and five cues of 0.30–1.30 seconds. Normalized peaks are 0.109–0.117 for ambience and 0.092–0.275 for cues, below clipping. This does not substitute for listening and mastering on physical devices.

## Limits

Checks were deliberately targeted under the user's instruction to avoid excessive automated testing. No long balancing simulation, retention study, multi-device thermal test or physical Android install was performed. Screenshots use a desktop portrait viewport and controlled progress fixtures; background HUD goals in developed fixtures are not a recorded full campaign playthrough. Motion settings and audio state behavior were checked, but frame-rate performance has not been certified.

Logs: `build/checks-0.7.log`, `build/capture-0.7.log`, `build/capture-0.7-errors.log` (empty). Screenshots: `docs/qa/screenshots/*-0.7.png`.

Android debug export completed successfully, including APK verification, with no script errors in the export log. Version code 7 / version name 0.7.0. Package: `build/android/ashen-covenant-0.7.apk`, 77,927,584 bytes. SHA-256: `7C1374B755F9A51D4500D25064EE1988424ED5B74C3D3843D0B03DF9840171DB`. Export log: `build/export-0.7.log`. This package is debug-signed for playtesting and has not been submitted to Google Play.
