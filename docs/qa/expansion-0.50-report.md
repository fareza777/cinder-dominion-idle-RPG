# 0.50 — The Far Marches and equipment-bound monster cards

## Delivered scope

The approved expansion is implemented in the Godot game. Content totals are definitions, not a claim that every encounter or full campaign has been playtested.

| Content | 0.49 | 0.50 |
| --- | ---: | ---: |
| Playable heroes | 5 | 8 |
| Enemies / monster cards | 60 / 60 | 120 / 120 |
| Items | 277 | 598 |
| Equipment | 82 | 182 |
| Materials | 125 | 286 |
| Crafting recipes | 102 | 208 |
| Story chapters | 11 | 18 |
| Progression contracts | 25 | 60 |
| Optional guardians | 7 | 12 |
| Talent nodes | 9 | 18 |
| Available talent points / full-tree cost | 60 / 75 | 80 / 120 |
| Runes | 3 | 12 |
| Hidden masterworks | 10 | 24 |

Seven foods, three potions and nineteen gathering activities remain. Hero/skill cap remains 100; three legacy relics still have forty ranks. Eight heroes now each have class skills and two paths. New heroes: Frostbound, Penitent and Duskblade. New content does not introduce stamina or activate paid services.

Six sequential regions contain nine encounters each, five new optional guardians and one roaming hunt. Regions provide guaranteed ordinary equipment materials, distinct status/mechanical emphasis, two-piece armor effects, first-clear supply-road rewards and additional talent points. Starless Bastion also requires the prior frontier completion. New story is brief and linked to regional victories. Earlier monsters retain optional card/rare-material value.

## Cards, builds and saves

Every card declares one to three equipment slot families. Ash Rat: Chest/Shield; Hollow Hound: Weapon/Hands. Both ring positions accept the Ring family. Tools remain ineligible. UI lists compatible gear and the authoritative command rejects incompatible insertion before changing stock or sockets. Duplicate card effects still do not stack. Removal/extractor rules are unchanged.

After validating an old save, incompatible installed cards return to Bag free of charge, without generating new-loot rewards. Migration is revisioned and idempotent; equipment is retained. Current saves with an invalid attachment are rejected. New fields for weapon attunements, regional claims and Depths checkpoints are optional for older saves and validated when present. Refinement/tempering follow the attuned equipment UID; attuned gear is protected from salvage/stack merging.

Six weapon attunements support Bleed, Burn, Chill, Poison, armor-based counters and execution tradeoffs. Additional talents, twelve runes, six regional armor sets and fourteen new masterwork effects use the same combat/status engine online and offline. No card is required by the sampled endgame builds.

## Farming and endgame

Regional equipment can be tracked directly. The upgrade objective identifies the actual missing nested ingredient and opens its sources; hunting remains an explicit player order. New deterministic equipment recipes do not depend on super-rare materials. Return reports expose the tracked upgrade and next step.

All twenty-four masterworks stay hidden until learned through a blueprint. Existing monster-drop and expensive rotating NPC merchant paths remain. A new optional research path grants field notes from an eligible source while it still has unknown blueprints; 200 notes from that source plus 5 Platinum restore one. Names/art of the undiscovered result are not shown in advance. Rare drop percentages remain hidden in game. Research is paged by six sources.

Depths rotate Burn, Chill, Bleed and Weaken threats. Every fifth room has a tougher guardian and stores a checkpoint. Re-entry starts after the checkpoint; defeat still discards only unbanked shards. Preview uses the actual resumed floor. The existing steady/perilous choice and weekly hunt board remain; its eligible optional-guardian roster expands to twelve. No login-streak penalty or free permanent automation was added.

## Art and phone layout

Thirteen new generated atlases: sixty enemy paintings, three hero portraits, twelve hero combat poses, three work-animation sheets, six region paintings, forty-eight item/material/masterwork icons and twelve individually illustrated rune stones. About 37 MB of PNG source assets. Provenance: docs/expansion-art-0.50.json and docs/runes-art-0.50.json. Characters face forward with sealed, hooded or bandaged faces. Rat/Hound keep the prior bandaged battle artwork. Some regional equipment/material IDs intentionally share an icon archetype; this is not 598 separately painted icons. Combat uses pose sprites and effects, not skeletal animation.

Phone captures at 412x892 cover all three new hero equipment pages, the regional route/equipment lists, card restrictions, compatible socket selection, talent tree, runeforge, research, recipe pagination, battle and work queue. Card/region dialogs also captured at 360x800 with 130% text. Visually inspected hero, battle, regional equipment, rune and large-text layouts: no observed text overlap in these views. Scrollable content remains accessible; these samples are not an exhaustive all-dialog/device audit.

## Actual verification

- Essential suite: 83 checks passed, including saved progress and existing online/offline equivalence. Ordinary auto-planner assertion excludes recipes explicitly requiring player-directed hunt materials.
- Expansion suite: 30 checks passed: exact counts/references, restricted insertion atomicity, legal effect activation, free/idempotent old-save migration, invalid new-save rejection, research spend/duplicate protection, attunement costs/effects/refinement, region reward uniqueness, rune loadouts, save round trip, discovery gates, Depths checkpoint/rotation and new-hero/rune/set/attunement online-offline equivalence.
- Real-pointer onboarding: all six actions, shell rebuild, completion, restored navigation, saved dismissal and narrow Skip passed.
- Capture suite: completed without script/runtime errors after correcting a ring-label lookup and new-enemy portrait fallback found in the first run.
- Combat sample: 25 deterministic prepared-build fights. Eight heroes each fought the first regional ruler, final regional ruler and final optional guardian. 23/24 won with the original offensive setup. Duskblade lost against the final optional guardian (101 HP peak hit, forecast flagged danger); changing to the existing safe route and Ward relic won (76 HP peak hit, 628 seconds, 215 meals). This is useful evidence of a viable defensive choice, not proof of full balance or campaign duration.
- Desktop navigation, Godot 4.7.1 Compatibility / GTX 1070: warm page construction 16–57 ms; next-frame readiness 28–100 ms. First Bag/Explore construction 319/272 ms. This prepared fixture now includes expanded inventory, so it is not an identical before/after comparison with 0.49. Asset caching remains, recipes are paged by 20, contracts by 10, research by 6 and supplies by 30. Physical Android responsiveness remains unmeasured.
- Editor import: no script parse errors. Existing duplicate-UID warnings from ignored local build copies remain. Known navigation-harness shutdown warnings (11 ObjectDB instances / 5 resources) remain. Whitespace check passed.

## Remaining limits

No physical Android installation/playtest, full fresh-save campaign run, long-term economy simulation, statistical drop study, device-memory profile or retention claim. Difficulty values and prices are initial expansion tuning. Rare-card collections are optional and are not included in a measured completion-time claim. This is a debug adventure preview, not a finished SSS/AAA release.

## Android package

Version 0.50.0 / code 51, existing package com.ashencovenant.prototype. APK: `build/android/cinder-dominion-0.50.0.apk`, 275187213 bytes (~275 MB decimal), arm64-v8a and x86_64. APK Signature Scheme v2 verified. SHA256: `3E7D5B836E13B1B5F95E5464036B2A105E3798195490C37D260E1E2286A3145F`.

Exporter reached `[DONE] export`; its child exited. The identified lingering console wrapper PID23776 was then stopped. No natural export-exit-zero claim. Existing application identity/signing preserved; this is an Android debug package.
