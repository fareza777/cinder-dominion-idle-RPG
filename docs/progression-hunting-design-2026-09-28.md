# Hunting, equipment and long-term progression

Status: proposed design, not implemented. All numbers below are initial tuning targets, not measured campaign balance. Existing release remains 0.37. User confirmed an offline NPC economy; no player-to-player market.

## Goal and current constraints

Hunt a chosen monster, collect materials, improve equipment, choose counters, defeat a stronger enemy, and advance the story. Rare cards create exciting discoveries without becoming mandatory campaign gates. Rest should change the activity rather than make the whole game unusable.

Source inspection: chronicle.gd grants at most 10 talent points from 250 combined melee XP per point; three nodes cap at five ranks. Three legacy relics cap at rank 10. paths.gd already supplies four build-level socket relics and up to three sockets, which must remain distinct from equipment cards. catalog.json contains 42 enemy definitions. Hero progression currently uses Bladecraft level, capped at 100; do not introduce another competing hero XP bar. Combat has timed special strikes but no unified timed status engine.

## Approach

Options considered: hard energy blocking every activity; soft fatigue reducing rewards indefinitely; hunt-only stamina with explicit rest. Recommend hunt-only stamina: preserves meaningful limits and clear drop odds, while gathering, cooking, forging and build preparation remain useful during rest. No hidden reduction of card chances when tired.

## Player journey

1. Choose hero and name. Follow the existing focused tutorial through a first hunt and first equipment upgrade.
2. First Supplies unlocks stamina and rest instructions. Tutorial hunts are exempt so an exhausted hero cannot block onboarding.
3. Choose a hunting target. Show useful drops, preparation, estimated duration, expected stamina use and next upgrade before starting.
4. Hunt with a finite order. Materials fund predictable equipment and relic progress; cards are additional rare finds.
5. At exhaustion finish the paid combat interval, then pause safely between encounters. Rest regenerates stamina; players can prepare supplies or perform non-combat tasks.
6. Resume the hunt manually. Rewarded assistance may resume it during its already-earned assistance window. Stamina recovery alone never grants free automatic queue orchestration.
7. Defeat a region boss to unlock a short story event, new materials and progression branches. Repeat with more demanding enemy mechanics.

English UI examples: "Hunt Ash Rats", "Stamina 84 / 120", "Resting — next hunt ready in 12m", "Requires 8 stamina to begin", "Card chance: 0.02% per victory", "Track this upgrade". Show one next action rather than a paragraph of lore.

## Stamina proposal

Capacity = 120 + 2 × (Hero Level − 1): 120 at Lv.1, 168 at Lv.25, 218 at Lv.50, 318 at Lv.100. Hero Level is the existing Bladecraft level presented consistently in this UI.

Regenerate one point per three minutes outside combat, online or offline; no regeneration during combat. An empty pool refills in 6h at Lv.1 and 15h54m at Lv.100. Higher levels therefore bank longer expeditions, not infinitely sustainable hunting. Display refill time explicitly; evaluate whether late-game refill feels too slow before shipping.

Charge a small encounter entry cost plus time spent fighting, with an enemy-specific ceiling. Initial threat bands: ordinary 1 entry + 1 per 30s; elite 3 + 1 per 20s; boss 8 + 1 per 15s; guardian 12 + 1 per 12s. These are starting values for simulation, not final settings. Faster kills improve efficiency; tougher monsters usually take longer and consume more. Enemy definition sets a maximum encounter cost to prevent an unwinnable fight consuming the entire pool.

Reserve the maximum cost at encounter start; return unused reserve on victory, defeat or voluntary retreat. Actual elapsed cost and entry cost remain spent even on defeat/retreat. Persist reservation and elapsed billing intervals to prevent reload refunds. If stamina cannot cover the reserve, do not start. Display estimated cost and required reserve separately. The current encounter can finish within its budget; timeouts resolve as retreat. Every enemy must have a finite combat deadline consistent with the reserve.

Offline simulation processes the same encounters, costs, rest and queue rules. Keep the existing 24-hour simulation horizon; it is not 24 hours of uninterrupted combat. Non-combat work does not consume hunt stamina. No stamina purchase or ad refill is proposed; existing rewarded queue assistance remains separate. Clock rollback cannot create stamina or refresh stock.

## Talents and relics

Replace the early ten-point ceiling with a staged tree: target 60 spendable points by Lv.100, spread across class identity, offense, survival and hunting utility. Tree holds more options than can be purchased, and permits only one major keystone at a time. Initial ten points remain obtainable early; later points require increasing combat XP and regional milestones. Late-game nodes unlock at Lv.50/75/100 and boss milestones, so farming weak rats cannot unlock the entire tree.

After Lv.100, finite Paragon chapters add alternate keystones and specialist choices through difficult hunts. Avoid uncapped additive damage/armor. New expansions can extend chapters without invalidating existing builds. Reset talents freely outside combat to encourage experimentation.

Keep the existing three relic identities and earned ranks. Extend them into four ascensions of ten ranks each, targeting 40 ranks per relic. First ascension preserves current effects; later ascensions add bounded utility and mutually exclusive traits rather than repeating +2 attack/armor forever. New ascensions require region-specific essence and hard boss cores, not only early fragments. Final rank values require balance simulation before implementation. Rank thresholds 10/20/30/40 mark meaningful choices; only one legacy relic remains active.

No retroactive loss of fragments, purchased ranks or points. Migration maps legacy talents to starter nodes with a free reset, and existing relic ranks to ascension one. New difficulty gates must not revoke already earned rewards.

## Equipment and cards

Add necklace, belt, left ring and right ring beside the six combat slots. Keep three gathering tools separate. Both ring positions accept the same ring item family but require different gear UIDs. Unique-tagged rings cannot be doubled. Armor set bonuses continue counting armor only.

Start with at most one card socket per eligible gear item and ten total combat sockets. Socket compatibility is explicit on every card. Cards attach to gear UIDs, survive presets and cannot occupy multiple items. No sockets on gathering tools in the first release. Card removal costs a crafted extractor but does not destroy the card; charge and transfer atomically. Equipped cards cannot be sold without removal. Warn on selling socketed gear, and offer removal first. Duplicate same-ID cards may be collected or sold, but only one is active per hero, including the two rings. Proc chances have global caps and internal cooldowns.

Proposed tiers: Rare 0.02% (1/5,000); Epic 0.01% (1/10,000); Legendary 0.005% (1/20,000); Mythic 0.002% (1/50,000), each per eligible victory. No guarantee after 1,000 kills. At 0.02%, the chance of no card after 1,000 kills is approximately 81.87%; median first card is 3,466 victories. Expected kills are not a promise. Long boss encounters make identical odds much harsher in real time: measure encounters per rested day before approving each boss rate.

Cards are optional build specialties. Ordinary materials, relic essence and equipment recipes provide reliable progression independently. Do not disguise fragments as a guaranteed card craft if the published card is meant to remain genuinely rare. Story completion and every required encounter must remain viable with no cards. Optional challenge builds can benefit substantially from well-matched cards without requiring a full Mythic collection.

## Card coverage: 42 enemy definitions

One distinct card ID per catalog enemy ID. The 15 regional tier cards share three art families with different framing and an explicit tier name; their effects evolve rather than requiring 15 unrelated illustrations. Descriptions below express intended behavior; numerical strengths and compatibility are not yet approved combat data.

| Enemy ID | Card effect direction |
|---|---|
| ash_rat | Scavenger: small bonus to common crafting-material yield; never raises card chance |
| hollow_hound | Pursuit: bonus damage against bleeding targets |
| grave_thrall | Gravebound: reduced bleed damage |
| cinder_bandit | Cutpurse: modest extra battle gold |
| chapel_guard | Vigil: a brief barrier after several incoming strikes |
| ember_wraith | Kindling: attacks can inflict Burn |
| bellkeeper | Last Toll: periodically resist an interrupt |
| wilds_1 | Thorn I: small armor penetration |
| wilds_2 | Thorn II: improve bleed application |
| wilds_3 | Thorn III: extra damage against armored targets |
| wilds_4 | Thorn IV: limited retaliatory damage with cooldown |
| wilds_5 | Thorn V: periodic strike gains armor penetration |
| marsh_1 | Drowned I: Poison resistance |
| marsh_2 | Drowned II: improve Chill application |
| marsh_3 | Drowned III: weaken enemy healing |
| marsh_4 | Drowned IV: improve healing received while debuffed |
| marsh_5 | Drowned V: brief barrier after cleansing |
| crown_1 | Crown I: Burn resistance |
| crown_2 | Crown II: reduced critical damage received |
| crown_3 | Crown III: improve Shock application |
| crown_4 | Crown IV: extra damage against weakened targets |
| crown_5 | Crown V: periodic execution strike below a health threshold |
| trial_wilds | Vigil's Edge: bleed-focused keystone tradeoff |
| trial_marsh | Unbroken Hymn: cleanse-focused keystone tradeoff |
| trial_crown | Sundown: low-health defense with cooldown |
| apex_wilds_1 | Marksman: improved critical damage against exposed targets |
| apex_wilds_2 | Mossback: shield capacity at an attack-speed cost |
| apex_wilds_3 | Emberwood: Burning targets take a bounded additional strike |
| apex_marsh_1 | Chainbound: resist Slow and Chill |
| apex_marsh_2 | Lantern: poison specialization with limited stacking |
| apex_marsh_3 | Leviathan: improve barriers at reduced healing efficiency |
| apex_crown_1 | Executioner: finisher damage with a cooldown |
| apex_crown_2 | Bishop: periodically cleanse one debuff |
| apex_crown_3 | Sovereign: improve one selected elemental affinity |
| secret_0 | Castellan: alternate mitigation of large incoming hits |
| secret_1 | Astral: periodic skill echo at reduced strength; cannot retrigger itself |
| secret_2 | Forgemaster: armor-breaking specialization |
| secret_3 | Silent Monarch: brief enemy skill delay, subject to boss resistance |
| secret_4 | Thorn Colossus: retaliation build with capped reflected damage |
| secret_5 | Glass Sentinel: critical potency with a defense penalty |
| secret_6 | Unlit Sovereign: high-risk damage while below a health threshold |
| hollow_depth | Hollow: bounded defense against escalating Depths pressure |

Rare for ordinary enemies, Epic for regional tiers, Legendary for trials/Apex, Mythic for secret guardians is the initial mapping; Hollow's rate must account for repeatable depth difficulty. Higher depth may improve ordinary rewards without silently changing card odds. Publish any explicit odds changes.

Art direction: concealed-face silhouettes, weathered painted scenes, restrained etched borders and readable labels outside the painting. No readable facial anatomy, oversized floating rune symbols, shiny casino frames or text baked into generated art. Each base enemy family gets recognisable art, plus deliberate tier variants. Produce art after card taxonomy and presentation are settled; none generated in this concept iteration.

## Merchant and market

Recommended first release: NPC buy/sell market, explicitly labeled merchant stock, with no implication of real player listings. Permanent basic supplies plus three rotating rare offers; stock refresh every eight hours with a visible timer. The first observed stock remains available for a full refresh interval rather than disappearing when a player returns after days away. No pushy last-minute purchase prompts.

Offers are tied to unlocked regions and use gold plus trade seals from hunting/contracts. Useful rare equipment, extracts and crafting materials rotate regularly. Very occasional Rare/Epic cards may appear; Mythic boss cards remain hunt-only initially. No paying to reroll. Purchase quantities, stock seed and refresh timestamp persist. Reloading cannot reroll offers or restore purchased quantities. Selling and repurchasing never earns net currency; sell value is strictly lower than buy value. Protect favorites, equipped items and quest essentials. Cards require a confirmation that shows exact identity and price.

A true player-to-player marketplace is a separate online project: server-authoritative inventory, loot, currency and trades, transaction recovery and duplicate prevention. Local editable saves cannot underpin a trustworthy shared economy. No backend or paid service integration is authorized by this draft.

## Elements and status engine

Separate damage types (Physical, Fire, Frost, Lightning, Poison, Shadow) from statuses. Fire is damage; Burn is its possible damage-over-time effect. Neither implies the other automatically.

First status set: Burn, Poison, Bleed, Chill, Freeze, Stun, Shock, Slow, Armor Break, Weaken and Wound. Freeze follows sufficient Chill; direct damage breaks Freeze. Shock periodically disrupts a skill rather than randomly canceling everything. Wound reduces healing; Weaken reduces attack. Supporting effects: Barrier, Regeneration and Cleanse. Resistances and durations are visible on enemy details after discovery.

Apply finite duration, max stacks and explicit refresh rules per status. One shared control-immunity window prevents alternating Freeze/Stun loops. Bosses shorten or resist hard control but still permit soft-control builds; immunity appears in the UI. Damage-over-time cannot recursively proc cards. HP-percentage damage and reflection have per-target caps. Offline ticks use the same event ordering and saved RNG as live combat.

Keep three highest-priority status indicators visible with remaining time/stacks; overflow opens a detail view. Use amber embers, pale frost, faint electrical arcs and understated mist consistent with the approved sprite battle. Keep hero motion, static enemy artwork, readable damage and reduced-motion behavior.

## Safe implementation sequence and acceptance

1. Versioned save migration, accessory positions and equipment presentation. Confirm legacy saves/presets, unique gear ownership and narrow-screen legibility.
2. Unified statuses and combat balance counters, then longer talent/relic progression. Confirm no permanent crowd-control loops and no-card campaign viability.
3. Cards, socket ownership and loot tables, with complete coverage for all 42 enemy IDs. Validate seeded probability code and recovery; do not try to prove rare odds by manually grinding.
4. Stamina, rest and offline integration. Confirm live/offline equivalence, reserve/refund boundaries, no clock-reset advantage and no tutorial dead end.
5. Persisted merchant, hunt-target guidance, card art and restrained reward presentation. Check sell/buy exploits and refreshing stock persistence.

Each stage should produce a useful versioned build with actual verification recorded. Preserve Android identity and existing saves. Limit checks to changed logic and a small phone-layout set; leave extended playtesting to the user. Do not export a new APK for a design-only change. A full campaign timing and drop-economy simulation is required before claiming these numbers are balanced.

Confirmed decision: NPC-only trading, fully offline. Outstanding tuning: sustainable hunts/day per threat band, stamina reserve costs, 60-point XP distribution, ascension trait strengths, card values and per-enemy odds. These are proposals, not shipped features or promises of AAA quality.
