# Ashen Covenant development

Engine: Godot 4.7.1 stable, GDScript, Compatibility renderer. Internal portrait prototype.

Execution is solo as explicitly requested. User requested minimal testing and will playtest personally. Retain build/import checks and compact save/economy checks; replace exhaustive TDD, repeated suites, and independent agent review with this narrower policy.

Open project.godot in Godot, or run the engine with --path pointing at this directory. Exported builds are placed in build/ and not committed.

## Art direction from 0.33 onward

Keep every depicted face concealed: opaque hood/veil or fully closed featureless helmet, with no visible eyes, nose or mouth. Include enemies, background statues, ornaments, work frames and fallback assets in art reviews. Do not reintroduce prior complete-face images from historical commits or QA screenshots. Preserve dark fantasy identity through cloth, silhouette, weapons and lighting. See docs/faceless-art-0.33.json for the reviewed asset inventory and prompts.

## Public identity from 0.35

Public title: Cinder Dominion: Idle RPG. Keep project.godot application/config/name as Ashen Covenant: it is the legacy desktop user:// directory key. ui/brand.gd and the Android package label provide the visible title. Keep com.ashencovenant.prototype and signing identity stable for upgrades. Brand art must be a transparent emblem on UI, without a rectangular matte or a portrait substitute. Stronghold is the village tab; Town groups its services. Internal village/refuge IDs remain stable.

## Main-page design from 0.36

Use RealmUI.scenic for art-led headers with text in container flow, RealmUI.section for quiet dividers, primary bronze buttons for immediate actions and secondary etched controls for tools. Keep the persistent Goals coach target. Inventory supply actions now live in pages.supply_details; hunt controls live in hunt_preparation and hunt_routes. Preserve source/potion/sale access when changing these views. New environment prompt and source: docs/page-art-0.36.json. UI screenshot bounds must compare logical Godot coordinates, not physical raster dimensions under canvas stretch.

## Battle direction from 0.37

User explicitly wants small full-body hero sprites with distinct attack poses, matching the earliest battle style, for all five classes. Do not substitute sliding portrait cards or the rejected articulated Warden puppet. Enemy art stays stationary; damage/skill overlays remain. Use restrained weapon trails, sparks and healing wisps, not oversized shield/crosshair/plus/magic-circle symbols. Runtime UV sprite mapping is in ui/hero_combat.gd; new skill metadata is transient combat-event data and must never alter balance or save schema.


## Equipment positions from 0.38

Use RealmEquipmentSlots.accepts/target/place/valid for equipment position mapping. Ring item family maps to ring_left or ring_right; never write an equipped.ring field. New rings do not stack, so each hand owns a distinct UID. When moving a UID remove its prior position, including in previews. Accessory recipes unlock at Smithing 30/60/90; armor sets still count only their five armor positions. Keep saved loadout/preset references when refining.


## Legacy progression from 0.39

RealmLegacyGrowth owns point milestones, advanced talent gates, relic ascension costs and bounded combat bonuses. New talent keys are optional on legacy saves; use get(key,0). Keep the three old fields required. Chronicle validation now needs kills along with XP. Relic rank base stat bonuses cap at ten; use relic_base, never multiply all 40 ranks by the old stat increment. Offline return talent deltas use earned(before), not the historical ten-point formula. Essence sources follow fragments_for(enemy), and the final ascension also spends a guardian core.


## Merchant stock from 0.40

RealmMerchant.sync observes wall milliseconds monotonically and refreshes persisted three-offer stock at expiry. Never consume model combat RNG for stock selection. UI persists stock immediately on opening; purchase passes current observation time and displayed revision to prevent buying a replaced offer. Keep offer table compatibility in mind when changing prices: current save validation matches serialized offers to pool(tier). Future price changes need migration/versioning of merchant stock. All gear sales use model.protected and require a separate confirmation UI.

## Hunting systems from 0.41

RealmCards maps gear UIDs to consumed cards. Socketed gear must remain count one and protected; refinement/tempering transfers the socket to a unique resulting UID. Duplicate active card IDs count once. Use separate card_rng; never consume combat RNG for card rolls. data/cards.json covers all enemy IDs. New fields are optional for old saves.

RealmStamina reserves encounter cost and refunds unused time on every ending path. Old in-flight saves without stamina_started incur no retroactive charge. Recovery only occurs outside combat, through simulation time. Paused manual hunts require explicit resume; only existing valid rewarded assistance may automate that action. Keep rest deadlines in advance() so offline chunking remains equivalent.

RealmAfflictions stores finite effects inside fight. Include tick deadlines in advance(); resolve deaths before attack actions. Shared hard-control immunity prevents alternating Freeze/Stun locks. Status events are not attack poses. Forecasts omit timed procs and must retain that visible limitation. All new card art must face forward with facial anatomy completely hidden, following the user's latest correction. Runtime crop boundaries follow the generated grid, not assumed equal cells.
