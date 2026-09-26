# Ashen Covenant 0.7 — integrated gameplay and presentation pass

Implemented solo under the user's request for a longer, comprehensive iteration. The work follows `iteration-0.7-plan.md`; English runtime, legacy campaigns and disabled commerce remain intact. The focus was on connected player problems, not another isolated collection screen.

## Problems resolved

| Finding | Delivered change |
| --- | --- |
| Equipment quality relied on random crafting/drop rolls, with no dependable use for a favorite piece. | The Ember Workshop refines one copper/iron combat item by one quality tier with guaranteed results, up to Legendary. Higher quality requires Smithing experience and earned materials. |
| Upgrading a stack could improve multiple copies for one cost or break saved equipment references. | Refinement splits exactly one copy, safely merges into an existing destination stack, preserves protection, and follows the improved piece in equipped slots, legacy presets and new loadouts. |
| Existing presets remembered gear but omitted the decisions that defined a build. | Three complete loadouts store equipment, stance, talents, relic, rune, food, potion and healing threshold. Validation occurs before any build choice is applied. |
| A finished or failed queue did not explain how a whole hunting session went. | A persistent, bounded history records 12 hunting orders: victories, time, gold, XP, fragments, loot rarity, meals and potions. Recalled, completed and defeated outcomes are distinct. |
| Refuge systems kept accumulating above the artwork. | The current objective and refuge illustration are followed by Journey, Armory and Supplies service groups. Existing features remain reachable through focused menus. |
| Battle environments used overhead map crops, and portraits only flashed. | Three original eye-level arena illustrations, subtle depth drift, breathing/lunge/impact motion, attack marks, ambient particles and a visible guardian third-strike warning. |
| Every action sounded the same and all places shared one simple drone. | Four original layered 32-second ambience scores and five differentiated cues, with gradual mood transitions, mute handling and background pausing. Settings sliders stay quiet. |
| Some details undermined clarity. | Correct singular/plural report text, explicit talent names and supply stock in loadouts, no unnecessary ingot plan when already stocked, equipment-rarity loot reporting, correct tool speed units, and updated handbook instructions. |

## Equipment progression

Open **Refuge → Armory → Ember Workshop**, **Hero → Refine equipment**, or the refinement action on a gear item. First Supplies unlocks the workshop. Only copper and iron combat gear can be refined; tools and worn starter items are excluded.

| Result | Required Smithing | Gold | Matching metal ingots | Scraps |
| --- | ---: | ---: | ---: | ---: |
| Fine | 3 | 40 | 2 | 2 |
| Rare | 6 | 120 | 5 | 6 |
| Epic | 12 | 360 | 12 | 15 |
| Legendary | 20 | 900 | 25 | 35 |

Refinement has no random failure or downgrade. It preserves total item quantity and only changes the quality of one piece. An Iron Sword contributes 10 attack at Rare, 12 at Epic and 14.4 at Legendary before the fighting-style multiplier and final integer calculations. The underlying quality multipliers already existed; this iteration makes higher tiers attainable through play. Costs, item contributions and the source of missing materials are shown before the action. No gold, ingots or scraps are spent when a requirement fails.

## Builds and hunt feedback

Wayfarer, Gatewarden and Oathbreaker are save slots, not fixed classes. Players build their own versions in Hero. A loadout selects existing food and potions; it does not create or reserve them. Equipment referenced by any loadout is protected from salvage. Applying a loadout is blocked during combat and fails without partial changes if gear or progression requirements are unavailable. Relic/rune ranks use the player's current upgrades. Gear-only legacy presets remain available.

Hunt reports start recording in 0.7. They do not reconstruct old sessions; a fight resumed from an older save is tracked from the update onward. An order remains active across individual victories and saves until its target is reached, the player recalls it or the hero is defeated. Reports do not grant currency: rewards are already delivered by the combat model. First-clear/quest supplies earned within a victory are included, as are equipment rarity and consumed food/potions. Only the latest 12 completed/recalled/defeated orders are retained, plus the active order. The active report is a snapshot when opened, with a refresh action.

## Presentation and audio

The new battlefield atlas depicts the Ashen Wilds road, Drowned Sanctum cloister and Obsidian Crown courtyard at ground level. Illustrated actors remain portraits. Motion includes restrained breathing, forward movement on attacks, impact strokes, environmental drift and particles; reduced motion disables these movements while preserving readable damage and danger indicators. The battery option uses fewer particles and the existing 30 FPS limit.

The hearth, forest, sanctum and crown each have a procedural ambient score built from harmonic layers, sparse chimes and filtered noise. Entering or leaving battle fades between moods. Refinement, equipping, collecting rewards, completing an order and defeat have distinct cues. Old events from long offline catch-up do not play a burst of sounds. These are original synthesized assets, not a claim of orchestral recording or final professional sound mastering. Asset provenance is in `assets/manifest.json`.

## Compatibility and production boundary

Save schema remains v1 with optional validated `loadouts` and `hunts` fields. Existing equipment identities, fields, progression and old presets remain loadable. No release signing, store publishing, live billing or advertisements were introduced.

This is a broader playable production pass, not completion of a AAA game. Full character animation, more authored chapters/enemy encounters, deeper equipment interactions, professional audio review, extended economy/retention tuning, cloud services and physical Android device coverage remain substantial work. No measured retention, device performance target or AAA certification is claimed.

Evidence: `qa/production-polish-0.7-report.md`.
