# 0.52 — Shattered Realms verification

## Delivered

- Explore selects a location before showing its encounter list. Old hunting grounds remain selectable for cards/materials; they are no longer appended to unrelated regions. Locked encounters stay undiscovered. Timed journeys remain a separate, clearly labelled action.
- Seven sequential late-game realms, 70 enemies/cards, 70 trophy materials, 63 equipment recipes and seven ruler milestones. First clears award seals and unlock crafting; ruler victories grant two talent points each. Enemies reuse existing measured two-pose silhouettes as regional variants, not newly generated monsters.
- 21 equipment rarities, preserving original indices. Deterministic duplicate fusion has increasing money/seal/skill/boss gates, protected donors and a fixed bottom confirmation button. Target UID, cards, traits and saved builds survive.
- 16 skills: three combat skills, thirteen professions. Seven new professions and seven tiers of their materials feed the forge; post-100 woodcutting/mining/fishing/cooking/smithing/alchemy activities complete the high-tier chain.
- User approved raising the cap during implementation: hero/professions now reach 130. Levels 1–100 retain their thresholds; post-100 XP has a steeper cubic tail. Realm entry requirements rise from 100 to 130. Earnable talent points increase to 100, retaining a 120-point tree so builds still require choices.
- Nine generated environment paintings, grouped profession navigation, new Bag/Skills headers, realm destination cards, merchant and forge scenery. Existing hero equipment stage, stone/iron materials and corrected battle silhouettes retained.

## Actual content counts

190 enemies and restricted-slot cards; 946 items (305 equipment, 439 materials, 190 cards, 9 foods, 3 potions); 329 crafting, 46 gathering, 190 combat activities. Twenty campaign locations plus sanctuary/trial/Depths categories. Twelve existing timed journeys and eight heroes remain. Seven regional story entries augment the existing 18-chapter story; no online community services added.

## Checks performed

- 83 essential simulation checks passed.
- 40 focused checks passed: catalog references, existing-save migration, malformed state rejection, region isolation/unlock order, all seven professions producing materials, offline/chunk parity, every fusion tier through Worldforged, protected donors, UID/socket/attunement persistence, level-130 queues and saves, 100-point talent budget.
- Confirmed every pre-existing catalog item, skill, activity and enemy definition is unchanged. New content is additive; old rarity indices and early XP thresholds are preserved.
- Real pointer input passed location entry, hunt preparation, profession recipe and actual Common→Uncommon fusion at 360×800 / 130% text. The forge confirmation now remains in the modal footer. Initial test clicked before scroll layout settled; the harness now waits for layout and the visible footer action passes.
- Existing six-step onboarding pointer test passed completion, shell rebuild, restored navigation, saved dismissal and narrow-screen Skip.
- Nineteen phone captures at 412×892 and 360×800 / 130% text. Reviewed world selection, local hunts, profession, inventory, hero, forge and new-region battle views. Art remains clear behind existing text veils; no overlapping text observed in these views.
- Seven prepared Warden boss samples passed after tuning excessive unavoidable pressure. With rarity indices 7/9/11/13/15/17/19, increasing hero levels and existing Star equipment: fights lasted 357/392/464/600/640/841/1025 seconds and consumed 119/128/150/195/243/271/342 meals. Largest observed hits were 54/57/65/73/77/82/82 HP. These are prepared-build samples, not full-campaign pacing estimates.

## Limitations

No physical Android play/performance test or multiweek economy audit. Not all classes/builds were sampled against the new bosses. Regional creature/item art reuses existing assets; new art is environmental. Thieving/Hunting are timed profession activities, not separate stealth/hunting minigames. World Boss/community pool/cloud multiplayer from the reference are not implemented. Existing UI harness shutdown warnings (11 ObjectDB instances / 5 resources) remain; no interaction/runtime script errors in the successful captures. No AAA/SSS completion claim, public publishing or paid-service activation.

## Package

Version 0.52.0 / code 54, same package/save identity. Android debug APK: `build/android/cinder-dominion-0.52.0.apk`, 300286509 bytes. APK Signature Scheme v2 verified; package `com.ashencovenant.prototype`, arm64-v8a/x86_64. Packed catalog independently checked: 946 items, 190 enemies, 16 skills and 21 rarities; realm data and art present. SHA256: `A4D07969751AC55B656E20D74F74321153B1BB678D2F7FBD80C9537D63A99EB1`.

Exporter reached `[DONE] export` and its child exited. The identified console wrapper PID15004 remained and was stopped afterward; no natural export-exit-zero claim. Whitespace check passed.
