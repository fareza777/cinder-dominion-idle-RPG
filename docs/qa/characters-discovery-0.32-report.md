# 0.32 — Characters, discovery and native test ads

Three free character choices precede a new journey: Warden (defence), Ranger (damage), Arcanist (armor penetration). Names accept 2–24 letters/numbers/spaces/apostrophes/hyphens. Existing journeys remain neutral until the player explicitly chooses a character from Hero; progress is retained. The choice is permanent for that journey.

Class skills unlock at Bladecraft 5 and improve at 25/50/75. Three initial attribute points plus one every five Bladecraft levels may be assigned to Might, Resolve or Focus; free resets are available outside combat. Attributes belong to the character, not equipment loadouts. Combat and forecasts share the class formulas. This is an initial balance pass, not a complete long-term balance study.

Enemy lists now omit inaccessible enemies. Existing unlock requirements remain in force: the first tutorial hunt requires three Ash Rats, rather than unlocking everything after one kill. Bestiary, hunting, mastery, regional and trial screens use the discovery filter. Reopen a dialog after an unlock to refresh its entries.

Four generated atlases provide three full-body portraits and 72 small work poses. Footer animation remains 64×54; equipment uses the selected portrait. Combat applies movement and impact effects to each class portrait; these are not skeletal characters or separate class battle-pose sets. Equipped armor does not replace the painted costume. Exact generation prompts: ../character-art-0.32.json.

## Verification performed

- Existing 83 essential checks passed.
- Focused character checks passed: legacy saves, names, selection locking, attribute budgets/reset, skill effects/ranks, save round trip, invalid allocations, combat restrictions, simulation chunk equivalence and sequential discovery.
- UI capture script passed: three selections through the actual confirmation control, corresponding equipment/footer art, attribute allocation, unavailable ads on desktop and narrow 360×800 at 130% text. Fourteen screenshots are under screenshots/*-0.32.png. Inspected character selection, equipment and starting bestiary captures.
- Android Gradle debug export with the native Poing AdMob plugin succeeded. A final export includes the closing-copy and stale-ad-callback fixes.

## Limits

No physical Android playtest, soft-keyboard inspection, native ad display, banner-inset verification, consent-flow test or production ad serving was performed. Capture shutdown reports 11 leaked ObjectDB instances and five resources still in use; the functional assertions passed, but cleanup remains to investigate. Character balance and endgame economy need player testing. SDK ads are explicit test controls, not scheduled live monetization. No billing or paid character entitlements have been implemented.

## Final artifact

Android debug APK: build/android/ashen-covenant-0.32.apk, 216,916,224 bytes, package com.ashencovenant.prototype, versionCode 32 / versionName 0.32.0, arm64-v8a and x86_64. SHA-256: 64333AAA0A9F7A923B0D532F6417CE6E0C14D228942CF4461E1C147B98809924. Final Gradle export exited 0. Manifest confirms demo application ID and native Poing AdMob registrations. An initial repeat-export failure was traced to Godot scanning generated Android resources; android/.gdignore prevents recurrence and generated .import sidecars were removed before the successful export.
