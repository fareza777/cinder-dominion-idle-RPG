# 0.41 — Monster cards, stamina and combat effects

Completes the core remaining hunting systems following accessories (0.38), talent/relic growth (0.39) and rotating NPC stock (0.40). All player-facing text is English. Existing package, project save directory and optional-field compatibility are retained. No paid service was enabled.

## Delivered

- 42 cards cover all 42 enemy definitions; catalog now has 178 items. Rare/ Epic/Legendary/Mythic drop probabilities are 0.020%/0.010%/0.005%/0.002% per victory. Each roll is independent, without pity. A thousand rat kills can yield no card. Card rolls use a separate persisted RNG.
- Every combat item can hold one card; tools cannot. Inserting consumes an owned card, splitting stacked gear safely. Extraction consumes a crafted Smithing Lv.20 extractor and returns the card intact. Attached gear is protected from sale/salvage. Refinement and guardian tempering transfer the socket to the resulting item. Equipping multiple copies of the same card does not multiply its effect.
- Collection hides undiscovered cards unless owned or attached; seven cards per page. Details show exact odds, effects, ownership, gear selection, hunt preparation and confirmed sale. Gear selection paginates twenty entries. Combat percentages apply in battle, not the base ATK/DEF totals.
- NPC stock has a 5% chance per eligible refresh of including one Rare/Epic card. Gold-only prices are 100,000/250,000, with resale 20,000/50,000. Legendary/Mythic remain hunt-only. Existing stock is preserved and no player market is implied.
- Stamina starts at 120 capacity and gains two each Bladecraft level, up to 318. Rest regenerates one per three minutes outside combat, including gathering/crafting/offline. Tutorial hunts are exempt until First Supplies is complete.
- Hunts reserve a maximum ten-minute encounter budget: ordinary 21, bosses 48, guardians/Depths 62. Actual cost is entry (1/8/12) plus elapsed time rounded up per 30/15/12 seconds. Unused reserve returns on victory, defeat or retreat. Ten-minute encounters retreat. A depleted manual queue stays paused until Resume; only already-earned, unexpired rewarded assistance may resume automatically. No free automation or stamina purchase was introduced.
- Timed effects: Burn, Poison, Bleed, Chill, Freeze, Stun, Shock, Slow, Armor Break, Weaken, Wound, Barrier and Regeneration; Cleanse removes one harmful effect. Damage-over-time cannot recursively trigger cards. Hard control is shorter on bosses with a shared six-second immunity window. Freeze breaks on a direct hit. Class effects unlock at Bladecraft 25, cards add rarity-scaled fourth-hit effects, and enemies have authored third-hit effects. Apothecary food can regenerate HP.
- Restrained status particles and readable remaining durations accompany the existing hero poses and static enemy art. Status ticks do not trigger false hero attack animations. Reduced motion suppresses the new particles. Hunt preparation, handbook and rest guide explain the loop.

## Art and phone review

Built-in image generation produced a 42-entry atlas. The first rear-facing draft was rejected following the user's correction; the final selected asset uses front-facing concealed faces, opaque veils, blank hoods and closed helmets, including veiled animals. No readable eyes, nose or mouth were accepted in the selected new card art. Existing historical assets were not all regenerated in this iteration.

Asset: assets/art/monster-cards-0.41.png (1106×1422). Exact prompts and all three source outputs: docs/monster-card-art-0.41.json. Uneven generated grid boundaries were measured and mapped with runtime AtlasTexture crops; the raster was not edited. Card-detail review caught neighboring-art bleed, corrected by those bounds.

Reviewed five captures: card detail/socket at 480×960; collection, rest and battle at rendered 360×720 with 130% text. Dialogs scroll, with no observed text overlap. Narrow battle uses a compact stamina button. Capture fixtures are not production starting inventories.

## Actual checks

- Essential suite: 83 checks passed, build/essential41.log.
- tests/hunting41.gd passed: legacy/new save round trips, all-enemy card coverage, insertion/stack split/equip/protection, workshop refinement, guardian tempering, paid extraction/intact return, stamina pause/manual resume/retreat refund, effect save validation/control immunity, and 120-second live-versus-chunked state equality.
- A bounded seeded search exercised an actual successful Rare roll at the production probability. One thousand independent card rolls did not change combat RNG. This tests wiring, not statistical distribution.
- Merchant card purchase and sale tested against actual eligible pool entries: 100,000 debit and 20,000 resale, with ownership changes. Five phone captures completed.
- Bounded fifteen-encounter sanity sample: all five prepared no-card classes won the first guardian; Warden won the last guardian; all five lost Depths 50. Six wins total. This establishes remaining difficulty in those fixtures, not exhaustive balance or proof of a viable counter for every new configuration. Details: build/balance41.json.
- Known capture shutdown warnings remain: eleven ObjectDB instances/five resources in use. No parser or assertion errors in the completed focused run.

## Limits and differences from the concept

No physical Android playtest, full campaign/drop-economy simulation or device performance/audio validation. Probabilities, stamina downtime and merchant prices still need sustained playtesting. No religious certification is implied by the visual review.

The design document remains partly aspirational: class keystones/Paragon, selectable ascension traits and trade seals are not implemented. Talent points/relic ranks are the shipped 60/40 system from 0.39. Elements label special attacks and match authored statuses; there is no independent six-element resistance-stat system. Shock delays attacks rather than selectively canceling skills. Statuses use wrapped text summaries instead of a three-icon overflow inspector. Existing music/SFX remain; this iteration does not claim new audio production.

Offline progression still has its existing 24-hour cap, with combat now additionally bounded by stamina. Local save/clock editing is not secured by a server. Existing combat forecasts explicitly exclude timed status/card-proc damage. These are preview systems, not a claim of finished AAA/SSS quality.

## Android artifact

Export reported `[DONE] export`. `build/android/cinder-dominion-0.41.apk`: 231,679,116 bytes. aapt confirms package `com.ashencovenant.prototype`, versionCode 41/versionName 0.41.0, Cinder Dominion: Idle RPG label, arm64-v8a and x86_64. apksigner verifies v2 signing. SHA256: `269DB4CD5A987F9D89D3326EB467CD1F76F74F0D215EA35D5562A4C23162DA4F`.

As with earlier exports, the console wrapper remained after export completion and the child exited. Only verified wrapper PID 25432 was stopped after artifact verification; a normal wrapper exit code is not claimed. Export scan reported duplicate UIDs from the existing ignored build/admob source copy; build/ and docs/ are excluded from the APK. Physical installation/upgrade has not been tested this iteration.
