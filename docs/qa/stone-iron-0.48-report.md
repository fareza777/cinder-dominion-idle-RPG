# 0.48 — Fortress stone and blackened iron

## Changes

The user approved the generated fortress floor, its extension into the upper/lower bars, and iron-textured cards, then requested remaining plain gray boxes receive the same treatment. This release combines those trials and applies the existing iron art through the shared frame style: cards, standard buttons and their states, dropdowns, input fields, popup panels, equipment slots, toast frames and modal dialogs. Existing nine-slice ornament, padding, focus outlines and distinct primary/disabled colors remain. Item cards retain only their subtle rarity light; texture drawing was removed from their subclass to avoid painting the material twice.

The floor is one static aspect-cover background behind translucent dark header/objective/task/navigation bars. The material wrapper renders the existing frame first, then the generated iron inset behind the control's text/children. Neither layer adds interactive controls or animation loops. Small progress tracks, focus outlines and map-node shapes retain their functional geometry; native operating-system dialogs are outside the game's theme. Menu illustration, splash and character/enemy art are unchanged.

Generated source provenance and full prompts are in `docs/floor-art-0.48.json` and `docs/iron-art-0.48.json`. No raster processing, additional generation in the final rollout, gameplay/balance change, save-schema change, live paid-service activation or publication.

## Verification

- `tests/all_iron48.gd`: 22 phone captures at 360×720, including 130% text views and the expanded inventory filter/search controls. Hero tabs, direct pointer item opening, filter disclosure, saved scroll position, talent and frontier node selection, Settings categories and horizontal layout checks passed.
- Inspected Stronghold, Settings, input/filter panel, large-text inventory/hero, menu, merchant and hunt-preparation captures. Other main/support pages captured by the same fixture. Nonpersistent simulated Warden save; its early objective is test state, not a normal max-level progression claim.
- Reused `tests/onboarding47.gd` against current code: full six-step pointer walkthrough, shell rebuild, completion dismissal, restored navigation, persisted dismissal and narrow Skip passed. Output saved to ignored build files.
- Previous trial checks also cover floor input pass-through and item opening. Existing exit warnings remain: 11 ObjectDB instances / five resources in use.
- Physical Android touch/performance and long-duration gameplay were not tested. No AAA completion claim.

## Package

- `build/android/cinder-dominion-0.48.apk`: 249,083,955 bytes.
- Package `com.ashencovenant.prototype`, versionCode 48, versionName 0.48.0; arm64-v8a and x86_64.
- APK Signature Scheme v2 verifies successfully.
- SHA-256: `E78516B58A8EEBE2B65668F6F3A2E6DF7A226BA2FC12A7B0C20528442E25666F`.
- Export reached `[DONE] export`, with no export ERROR lines. The child exited; the known lingering console wrapper was inspected and stopped. No natural exporter exit-code-zero claim. Existing helper-asset UID scan warnings remain.
