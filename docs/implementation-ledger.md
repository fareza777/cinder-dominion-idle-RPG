# Execution ledger — plan: docs/superpowers/plans/2026-09-25-ashen-covenant-foundation.md

User approved implementation, chose solo execution, and explicitly reduced testing on 2026-09-25.

Ruling: user-requested light checks supersede exhaustive TDD and reviewer agents. Cost: broad gameplay balancing and device coverage remain for user playtest.

Preflight: content -> state -> transactions -> queue -> combat -> save -> presentation have shared dictionary contracts. Use compact domain modules with centralized state mutation, bounded step-based catch-up, and native Godot controls. All domain event timers use simulation time. Visual effects never supply rewards.

Status: playable foundation implemented on feat/ashen-foundation; debug APK exported. No gameplay code existed at baseline.

Implemented: catalog, centralized model commands, production reservation/refund, queue targets, melee combat and progression, tutorial/unlocks, equipment and presets, save checksum/rotation, 24-hour catch-up, five screens, art/audio and Android export.

Implementation decisions: compact `game/model.gd` and `game/save_store.gd` replace the larger planned module tree. UI uses reusable native controls from `ui/style.gd` and `ui/pages.gd`. Domain state is centrally mutated, not immutable copies. English uses paired strings and remains incomplete instead of shipping complete CSV localization. Save schema v1 is validated; no legacy migration exists because there was no previous released schema. New fights begin immediately after a victory, with their first attack delayed by the combat timer. Presentation uses animated embers and portraits, not skeletal actors. These are explicit foundation limitations, not claims of full design completion.

Verification policy: nine meaningful domain checks, engine import/startup, visual captures and Android installation/startup only. Full stress/device matrices and balance playtests deferred per user direction. Asset manifest and README describe the delivered build and remaining milestones.

## 0.2 experience upgrade

User requested clearer English-first UX across the game, cinematic opening, onboarding, New Game/menu, About/Share/Rate. Implemented solo directly under this authorization. New flow module `ui/experience.gd` handles front-end and help screens; `game/journey.gd` supplies state-derived guidance. Save schema v1 stays compatible with optional validated experience metadata. New Game archives can be restored from Settings. Remaining full-game content scope is unchanged. See `docs/experience-0.2.md` and `docs/qa/experience-0.2-report.md`.

## 0.3 gameplay upgrade

User requested clearer, easier, deeper gameplay and improved visuals. Implemented solo: supply-chain planning, three combat styles, eight contracts, three refuge upgrades with three ranks each, best-gear action, selected-food preparation, encounter estimates and battle feedback. New logic is in `game/progression.gd`; dialogs in `ui/gameplay.gd`; battle presentation in `ui/battle_stage.gd`. Minimal verification retained: existing essentials plus four relevant checks for planning/accounting, reward persistence and offline skill consistency. See `docs/gameplay-0.3.md`.

## 0.4 clarity and long-term progression

Implemented solo under the user's continuing direction. Clear first action and condition-based preparation advisor; illustrated world map with three regions / 15 expedition tiers; three relic collections with ten ranks, one equipped slot and targeted guaranteed fragments; three talent paths / fifteen ranks with a ten-point allocation budget and free respec; carry-forward daily bounty board; expanded offline report and skill-unlock training links. Monetization direction now includes optional rewarded AdMob: only the disabled provider boundary/configuration is added, no SDK/live purchases/ads. Original map generated through the imagegen skill. The brainstorming skill guided scope; user instruction to work independently takes precedence over repeated approval gates. Four new focused invariants added to existing essentials. Full balance/device/retention work remains for playtesting.

Additional steering during 0.4: English-only runtime and catalog, restrained dark-fantasy copy, region-specific lore, four long-form offline work orders with batch/output/XP/time previews, and direct training links from blocked recipes. Existing language preferences remain loadable but presentation always uses English. Verification: 22 domain assertions and targeted rendering, with Android installation reserved for user playtesting.

## 0.5 review and polish

Implemented solo under the user's request for a deeper review. Applied the redesign-existing-projects skill to inspect existing flows and remove friction without replacing the Godot stack. Added current-build hunting-ground comparisons, region-scaled fragment payouts, three distinct guardian mechanics, original guardian portraits generated with imagegen, fixed modal actions, projected work-order levels, accurate relic healing copy and recent simultaneous battle feedback. The source/visual audit and remaining production gaps are recorded in `docs/review-0.5.md`. Four targeted domain assertions were added; the full essential set now contains 26. Broad playtesting and physical-device validation remain with the user this round. No monetization provider was enabled.

## 0.6 Runeforge and regional field records

Implemented solo after the user's request to keep raising quality. Added three mechanically distinct runes with three ranks, regional discovery, exact resource costs and explicit equip; nine one-time regional field records counting historical and offline victories; a current-build comparison using copied state; shared player/enemy damage rules for live combat and forecasts; English guidance and three original generated rune artifacts. Brainstorming and imagegen skills informed this iteration. Existing independent-work and light-testing instructions remain in force. Added six focused invariants and button-level UI checks. Details: `docs/runeforge-0.6.md` and `docs/qa/runeforge-0.6-report.md`. No live monetization or publication.

## 0.7 integrated production pass

Implemented the longer solo iteration in `docs/iteration-0.7-plan.md`: deterministic equipment refinement through Legendary; complete build loadouts; persistent bounded hunt records; reorganized refuge services; original regional battle environments and expanded portrait effects; original layered regional ambience and differentiated action/outcome cues. Imagegen supplied the three battlefields; audio synthesis is reproducible with `tools/make_score.py`. Source and rendered-screen review drove wording, stock, rarity, units and navigation fixes. Eight additional focused domain assertions bring the total to 40; real refinement-button and silent audio-state integration were checked. Extended player balancing and physical-device coverage remain for playtesting. Details and limits are in `docs/production-polish-0.7.md`.

## 0.8 Guardian Trials

Solo iteration: three optional two-phase guardian trials; latched phase save state; one-time Epic rewards with exact hunt accounting; field-record integration; accessible trial hall and endgame Journey guidance. Existing artwork reused. Six targeted checks added to the existing lightweight suite, seven portrait UI captures, Android debug export. No monetization or publishing actions.

## 0.9 Combat and journey polish

Solo: distinct procedural portrait states, reduced-motion and battery handling, focused English narrative revisions, duration-based hunt planning with cumulative food budgeting, finish-current-fight command with explicit queue-cancellation confirmation. Four targeted checks added; full lightweight suite 50 passes, seven UI captures. Android debug APK exported for user playtest; no physical-device or AAA certification claims.

## 0.10 Progression clarity

Solo clarity pass: three-tab Progress & farming guide, direct activity links, explicit resource purposes and unlock rules, minimum required ingot batch for Smithing 10, practical menu names and simpler English. One focused check added (51 total), five UI captures including first-objective button smoke. No new save schema or monetization.

## 0.11 Hunt review

Solo: selected report view, comparable per-victory hunt metrics, item-specific supply accounting, crafting restock links, repeat planner and latest report access on Refuge. Legacy reports remain truthful and compatible. Three targeted checks added (54 total), seven isolated UI captures and Android debug export.

## 0.12 Upgrade preview

Solo: read-only build/combat preview for refinement, unlocked-enemy selector, explicit bagged-item equip assumption, visible cost summary and missing-material routes. Above-cap display fixed. Three targeted checks added (57 total), four phone captures, Android debug export.

## 0.13 Story, motion and leveling

Solo: generated three-scene narrative art, seven milestone-gated story chapters, regional cast effects, named style skills, dialog/button motion and minimum-width fix, next-level recipe guide and non-blocking level feedback. Three targeted checks added (60 total), eleven phone captures. Original art provenance recorded; no new mandatory save fields.

## 0.14 Queue recovery

Solo: atomic dependency prepending for blocked crafting, queue status/progress polish, stale-action guards and Smithing batch-cap fix. Four targeted checks added (64 total), five phone captures and Android debug export.

## 0.15 Equipment clarity

Solo: item comparison using total build stats, actual tool time preview, same-dialog equip confirmation and explicit combat lock. Three targeted checks added (67 total), five phone captures and Android debug export.

## 0.16 Return flow and continued iteration

Solo: clearer offline time/cap reporting, level unlock recap, queue status and direct follow-up action. Three targeted checks added (70 total), five captures and Android debug export. User requested ongoing continuation; hourly heartbeat continue-ashen-covenant-development is active for this thread.

## 0.17 Relic farming clarity

Solo: explicit ready/farming/maximum states, direct upgrade action, truthful full-goal versus 100-fight batch, duration and cumulative food budgets, preserved enemy art/mechanics, current-to-next equipped bonus. Three targeted checks added (73 total), six phone captures and Android debug export. No save migration or economy changes.

## 0.18 Action-first direction correction

User explicitly rejects excessive narrative. Preserve this preference in future iterations: concise labels, quantities, progress and direct actions on routine screens; story and detailed teaching are optional. Reference listing and five official store images reviewed, including actual combat/offline layouts; not installed or played. Replaced four-page onboarding, bypassed mandatory cinematic, condensed objectives/farming/activity UI, removed repeated flavor and chapter notifications, made early hunt targets visible sooner. Ten phone captures with real first-task button smoke, existing 73 checks, Android export. See docs/action-first-0.18.md.

## 0.19 Forged UI surfaces

Solo: shared nine-patch SVG metal frames, corner ornament, bronze primary actions, recessed inputs, themed dropdowns/popups/switches/sliders/scrollbars, activity bar and navigation. Text-safe insets and short-word wrapping fix. Nine captures including advanced count input and 130% text; real queue-button smoke; existing 73 essential checks. Vector templates explicitly added to export includes. Keep the 0.18 action-first direction; no extra narrative introduced.

## 0.20 Hunt Mastery

Four enemy-specific ranks integrated into battle, offline progression, reward previews and fragment goals. Existing victories count. Four focused checks added (77 total), seven phone captures. Direct Realm Idle PC playtest requested; Google Play Games 26.9.341.0 subsequently installed; launch automation stalled and the user aborted. Realm Idle itself has not been installed or played.

## 0.21 Live mastery progress

Solo: mastery collection counters, detail rewards, milestone bars and hunt batch actions now follow live victories without reopening the modal or resetting scroll. Actions calculate the current milestone when pressed. No economy or save changes. Existing 77 essential checks plus a focused UI capture script exercising a real rank-up, updated action, collection counters, maximum rank and dialog cleanup. Five phone captures, including narrow 360x800 at 130% text. APK export and details in docs/qa/live-mastery-0.21-report.md.

## 0.22 Guided onboarding and original audio

User requests clear highlight-based step-by-step onboarding and thematic SFX/music. Solo: optional persistent six-step focus overlay follows actual Goals, task, Begin, Equip and progress controls; skip/replay, large text and motion settings respected. Four original 64-second stereo arrangements and nine synthesized cues, looping two-voice music crossfades, overlapping SFX, damage-event sounds and SFX preview. No save reset or economy changes. 77 essential checks and a focused real six-task UI walkthrough with nine phone captures; audio loop/mute/pause/transition checks. See docs/guided-onboarding-0.22.md and QA report. No physical Android or subjective device listening test.

## 0.23 Guided material recovery

Solo follow-up to onboarding: focus follows missing-material planning and the real Gather & craft action, existing queues get a fixed manage action, queued goals explain ordering, and active crafting no longer reports false material blockage after reserving inputs. No save schema or balance changes. Existing 77 checks plus focused UI plan-completion/reserved-input/queue-preservation smoke, five phone captures including narrow 130% text. See docs/qa/guided-recovery-0.23-report.md.

## 0.24 Focused taps and sound room

User reiterates focused onboarding and thematic audio. Added four input shields around the highlighted real control, retaining Skip; pointer-event smoke confirms off-target navigation blocked and Goals/action/Begin/Skip work. New sound room previews four existing original score tracks and five cues; weak dialog ownership returns music to automatic mood on close. No new audio assets, economy or save changes. Four captures, narrow 130% layout, essential checks and versioned APK.

## 0.25 Ascension expansion

User asks for a substantial SSS-directed expansion and many new art assets. Solo: 56 new items, 44 new recipes, 12 gathering actions, 9 Apex encounters and 17 contracts; four material bands at 25/45/65/85 and Smithing recipes through level 100. New gear integrates with matching-metal refinement and loot. Journey adds nine Apex objectives (39 total). Skills defaults to available recipes. Three original generated atlases contain 29 painted tiles, copied into assets/art and used by the runtime. All old catalog definitions preserved byte-value-equivalent. Six focused checks added (83 total), phone captures, versioned debug APK; balance and physical-device limitations documented.

## 0.26 Ascension next actions

Solo: the tier footer now follows current work, skill requirements, crafting, equipment review/refinement and Journey/Apex access. Counters and training buttons update while open; clicks recalculate their action. Stronger equipped weapons skip lower-tier sword crafting. Existing saves and economy unchanged. 83 essential checks and five phone captures with real plan/queue/equip button signals; narrow 360x800 at 130% text inspected. See docs/qa/ascension-guidance-0.26-report.md.

## 0.27 Audit implementation, first delivery

User authorized all recommendations from docs/full-audit-0.26.md. Solo: persistent upgrade targets, advanced work orders, improved training selection, Apex field progress, optional doctrines/loadouts, tier bounty rewards, inventory sort/filter/paging, readiness and bestiary. Original 16-pose combat atlas, Ogg music conversion and budgeted asynchronous offline simulation on a copied state. 83 essential checks, domain checks, async state/report equivalence and 12 phone captures; Android debug APK. Details: docs/qa/audit-upgrade-0.27-report.md. IMPORTANT: full scope is not complete; subsequent autonomous runs must read docs/audit-delivery-roadmap.md and continue its outstanding priorities. Never claim full AAA/SSS completion.

## 0.28 Armor identity and loadout comparison

Solo continuation of the audit: four derived two-piece armor bonuses in shared combat/forecast, set collection and crafting routes, before/after equipment set summary, and read-only saved-build comparison for an unlocked hunt. Existing gear and saves participate without schema migration. Numeric auto-equip limitations explicit. 83 essential checks, focused threshold/effect/save/read-only checks, four-build Lantern Widow sweep with chunk equivalence and six phone captures. Versioned debug APK; full balance/device limitations in docs/qa/armor-sets-0.28-report.md. Continue remaining audit items from docs/audit-delivery-roadmap.md.

## 0.29 Training plans

Solo: target-level training batches for six gathering/crafting skills, with 15/60/240-minute limits, dependency materials and XP, projected level, and persistent optional goal in Skills. Recomputes against current state on start; existing work is preserved. Preview uses a cloned model to avoid lazy progression mutations. Same recipe continues through unlocks; next visit recomputes the available recipe. Save validation handles integer-valued JSON numbers. 83 essential checks, focused batch/goal/save/offline-equivalence checks and five phone captures, including 360x800 at 130% text. APK version 29 exported. See docs/qa/training-plans-0.29-report.md; broader audit remains ongoing.

## 0.30 Clear onboarding and completion input fix

User reports unclear darkened onboarding and stuck final Continue. Reproduced actual pointer failure after shell rebuild: preserved coach drew above new UI via z-index but hit testing reached later sibling controls. Active coach now moves to the end of sibling input order. Removed coach dimming and modal dimming during guidance, including welcome; retained focus border, arrow, off-target input shields and Skip. Shorter concrete six-step instructions and next-goal completion copy. Focused real-pointer walkthrough passes all six tasks, rebuild at start/end, final dismissal, resumed navigation, saved inactive flag and narrow large-text Skip/Continue. Six captures; versioned APK. No economy/save-schema changes; no physical Android test. See docs/qa/onboarding-0.30-report.md.

## 0.31 Task-bar animation and hero equipment

User clarified animations belong in the small bottom queue bar, not large page scenes. Delivered a 64x54 thumbnail shared across pages, four original poses for each of six gathering/crafting skills, existing combat art for hunt thumbnails, simulation-time animation, waiting freeze, reduced motion and 15/30 redraw caps. No large activity scenes added. Queue counters update live and completed tasks refresh automatically. Hero has original full-body art with six interactive anatomical slots, ghost icons for empty slots, rarity borders, owned-item selection and existing compare/equip flow; three tools remain accessible below. Base portrait does not visually swap armor. Targeted UI script and six-step onboarding regression passed; 16 phone captures, two generated PNGs with exact prompt manifest, versioned debug APK. No save schema/economy change or physical Android test. See docs/qa/activity-equipment-0.31-report.md.

## 0.32 Characters, discovery and Android test ads

Solo user-directed overhaul: three free named characters with distinct stat trade-offs, class skill ranks and freely resettable attributes; optional profile preserves legacy saves until chosen. Sequential discovery hides unavailable enemies across hunt/bestiary/mastery/region/trial views. Four generated atlases supply three portraits and 72 work poses in the small footer and Hero equipment. Native Poing AdMob 5.1.0 integrated with official demo IDs and explicit Settings controls for banner/interstitial/rewarded; production disabled, no billing/IAP. 83 essential checks and focused character/UI checks passed; 14 phone captures and Gradle APK. Native ad serving, physical-device layout/keyboard, production consent and broad balance remain unverified; shutdown cleanup warnings recorded. See docs/qa/characters-discovery-0.32-report.md and docs/monetization-boundary.md.

## 0.33 Concealed-face art and two additional characters

User requests replacement of complete faces across all game art plus two new classes. Audited 19 runtime PNGs and SVG UI/icon assets; 15 generated outputs replace 13 original PNGs and add three, with legacy fallback also replaced. Includes heroes, 120 work frames, enemies, guardian/Apex portraits, combat poses, story smith, background statues and fish icons. Six environment/object atlases retained after inspection. Reaver and Apothecary add boss-damage and food-healing choices through shared combat/forecast rules; all five remain free. Name input moved above a two-column selector. 83 essential checks, five-class save/chunk tests, new rank-threshold tests and 18 UI captures passed. No physical Android test or religious certification; historic screenshot evidence is excluded from export. Details: docs/qa/faceless-roster-0.33-report.md.

## 0.34 Optional guardians, build paths and rewarded assistance

Solo implementation of approved endgame package with seven concealed-face optional guardians, sequential locations, two-stage unique recipes, first-clear cores, 8% unique loot and eight-win/16-seal guarantee. Four socket relics, two paths per class, validated loadouts, tempering, targets/routes, mastery yield, carry-over choice contracts, weekly targets and escalating bank-or-risk Depths. Adaptive single-cycle assistance is earned-reward-only for four simulated/offline hours; test IDs, production blocked. 123 items, 42 enemy definitions, 143 activities. Bounded 195-encounter baseline plus 180 counter candidates and 30 extra-seed checks; all five classes have viable selected counters at guardians 3/5/7, fixed max builds still fail deep threats. 83 essential and 38 focused checks, existing five-class checks and 13 phone captures; versioned APK. JSON optional-path numeric decoding and accurate reward reporting corrected. See docs/qa/endgame-0.34-report.md and raw balance JSONs. Device ads/performance, full campaign pacing, exhaustive balance and shutdown resource cleanup remain unverified/unresolved. No AAA/SSS completion claim.

## 0.35 Cinder Dominion identity

Public title changed to Cinder Dominion: Idle RPG. Two built-in image generations produce a final transparent iron-crown/ember emblem for splash/menu/header/launcher, replacing the old portrait in the header. User explicitly rejected a square logo background; final PNG alpha and menu screenshot confirm its removal. Stronghold replaces Refuge in navigation and help, Town replaces Refuge Services, About/Share/Rate updated. Legacy project name/user directory and Android package retained to preserve saves. Six phone captures include narrow 130% text and saved-journey menu. No economy changes; no physical Android mask validation. Detailed next-page recommendations in docs/premium-ui-direction-0.35.md; those broader redesigns are recommendations, not delivered changes.


## 0.36 Premium main-page presentation

Solo user-directed visual iteration across Stronghold, Explore, Skills, Inventory and Hero. One original four-scene environment atlas, scenic headers, restrained shared secondary buttons and navigation, serif modal titles, larger icons, two-column inventory and supply-detail actions. Hero equipment leads the page; hunt preparation and advanced routes remain accessible in compact dialogs. Existing onboarding/save identity preserved. UI capture/action checks and real-pointer six-step onboarding pass; requested small window renders a 360x720 viewport at 130% text with current desktop stretch configuration. APK 36 exported and package/version verified. No balance changes or physical-device verification; existing shutdown resource warnings persist. See docs/qa/premium-pages-0.36-report.md. Deeper system dialogs inherit styling but bespoke redesign of every nested view is not claimed.


## 0.37 Five hero battle sprites and restrained effects

User rejected an articulated Warden/Ash Rat experiment, clarified that heroes should be small full-body sprites changing attack poses like the original battle, and requested static enemy art plus elegant non-symbolic effects for all classes. Final implementation: twenty generated poses across five classes, shared battle/queue sprites, static enemy rendering, class-specific trails/sparks/healing wisps and accurate transient skill tags. No combat math/save changes. Five-class pixel/motion checks, real trigger/rank/boss-gating checks, essential suite, six phone captures and a four-second visual recording. Original puppet experiment archived under ignored build/experiments and not exported. Versioned Android debug APK; physical-device performance unverified and existing shutdown warnings remain. See docs/qa/hero-battle-0.37-report.md.


## 0.38 Accessory equipment foundation

First implementation stage of the approved long-term hunting design: necklace, belt and separate left/right ring positions; nine Smithing recipes at levels 30/60/90; original vector icons; ten-slot hero layout; bag filters and hand-specific comparisons. Distinct ring UIDs, shared slot compatibility, equip-best, save/preset/loadout validation and workshop refinement preserve ownership. Existing saves remain compatible without a rewrite. 83 essential checks and focused ownership/crafting/refinement checks passed; four phone captures including narrow 130% text. Full campaign accessory balance, physical Android testing and remaining stamina/card/merchant/talent/relic/status stages are outstanding. See docs/qa/accessories-0.38-report.md.


## 0.39 Late-game talents and relic ascension

60 earnable talent points gated by Bladecraft and boss milestones; six advanced shared talents, 75 total possible allocations and free resets. Relics grow to rank 40 with bounded specialist bonuses, three new essence materials from stronger enemies, ascension level/boss gates and guardian cores for the last ten ranks. Legacy allocations, base bonuses, save identity and loadouts retained. 83 essential checks, focused gate/cost/save/offline combat checks and four phone captures passed. Full pacing balance, physical Android verification, selectable relic traits/class keystones, cards, stamina, statuses and rotating NPC merchant remain outstanding. See docs/qa/legacy-growth-0.39-report.md.


## 0.40 Offline rotating merchant

Three persisted offers per eight-hour observation window, progress-gated stock through Smithing and regional bosses, Rare accessory possibilities, fixed supplies and protected equipment sales with explicit confirmation. Snapshot revision prevents stale purchases; independent stock RNG preserves combat randomness. Gold-only current economy; cards and trade seals deferred. 83 essential checks plus focused stock/save/clock/protection checks and actual UI signal activation passed. Three phone captures including narrow 130% text. No physical Android verification or full price/pacing study; local clock/save manipulation is not claimed secure. See docs/qa/merchant-0.40-report.md.

## 0.41 Core hunting systems and frontal concealed card art

42 enemy cards, 178 items, separate drop RNG, one socket per combat item, extraction and safe refinement/tempering transfer; Rare/Epic NPC stock and confirmed card sales. Level-scaled stamina with reserve/refund, offline rest and explicit manual resume. Shared timed effects, class/card/enemy sources, restrained particles and English guidance. Three image generations culminate in frontal veiled/hooded/closed-helmet card art after the user's correction. 83 essential checks, focused ownership/save/offline/merchant/stamina tests, fifteen bounded balance encounters and five phone views. Long campaign pacing and physical Android performance remain unverified. Further concept features are explicitly distinguished in docs/qa/hunting-systems-0.41-report.md; no AAA/SSS completion claim.

## 0.42 Rest readiness and safe resume

Next queued hunt, exact reserve deficit and live rest countdown lead the rest dialog. Resume activates only when ready, hides without a pending hunt/during battle, and closes the modal after starting combat. Explore and queue use matching readiness states. Command validation rejects premature resumes without changing queue/stamina/pause. Rules moved to a separate guide; no balance or save-schema changes. 83 essential checks, focused threshold/live-button/save checks and three narrow 130% screenshots passed. Physical Android playtest and known shutdown resource warnings remain outstanding. See docs/qa/rest-clarity-0.42-report.md.


## 0.43 Expanded world, rare finds and a stamina-free economy

User superseded stamina and requested old enemies retain rare-card/material value while late-game XP, equipment and currency remain meaningful. Removed stamina scripts, UI and limits; save migration preserves combat levels/fractional progress, removes obsolete reserve fields and retains numeric wallet units as Silver. Added Gold/Platinum denomination display, longer combat-only XP curve, authored reward tiers, revised workshop/relic/temper costs, versioned NPC prices and repeatable provisions.

Expanded 42 to 60 enemy definitions across three sequential frontier regions, with 18 new cards, nine one-time objectives and four story chapters. All 60 enemies now have distinct ultra-rare materials, generated item art and crafting uses. Ten guaranteed Legendary masterworks have individual implemented combat effects and progressively obtainable recipes. Six selected art atlases include frontal concealed enemies, all rare materials, equipment and currencies. Existing 15 trial tiers count as enemy definitions; no claim of 60 wholly different species.

83 essential checks, focused migration/currency/1,000-rat/crafting/drop/claim/offline checks and seven 360x720 views at 130% text passed. Thirty bounded five-class balance encounters and an eighteen-encounter Warden route checked increasing difficulty and obtainable recipe order. Historical shutdown resource warnings remain; long campaign pacing, all class routes and physical Android play are unverified. See docs/qa/economy-frontiers-0.43-report.md for artifact and limitations. No paid services or publication.


## 0.44 Copy cleanup and focused hunting screens

Removed visible card/material probability numbers and verbose drop explanations at the user's request, including older expedition/relic chance copy. Runtime odds and content data remain unchanged. Hunt preparation now leads with portrait, forecast, rewards and food; optional enemy/loot details retain mechanics, sources, first-clear rewards and forecast limitations. Crafting mastery is collapsible, duplicate missing-material actions removed, stale toast overlays hidden on modal open. Shorter card/masterwork/wallet/merchant copy, grammar and repeated phrase fixes, refreshed About counts. Bestiary is eight entries per page and includes frontier filters. Existing art is reused in compact masterwork rows.

Focused UI actions and six narrow 130% captures passed; Begin actually started combat, details expanded/collapsed, bestiary paging and frontier filtering worked. Existing shutdown warnings persist. No gameplay balance/save change or physical Android playtest. Versioned APK and recommendations documented in docs/qa/readability-0.44-report.md. Applied redesign-existing-projects skill within the existing Godot UI stack.


## 0.45 Recognizable header currency

Replaced the tiny S/G/P header text with cropped existing coin art and individual denomination amounts. Silver wheat coin, gold crown coin and octagonal platinum gem coin remain visually distinct. Nonzero denominations display highest first; an empty wallet shows zero Silver. Coin buttons open a wallet with larger matching icons, full English names and grouped exact balances. Very large header amounts use K; full amounts remain in wallet/tooltips. Menu/title alignment stays centered as rows grow. No economy/save/art-generation change.

Focused zero/early/mixed/large-balance visibility and wallet-action checks plus five 360x720 views at 130% text passed. Existing shutdown warnings remain; no physical Android verification. APK and verification recorded in docs/qa/currency-icons-0.45-report.md.


## 0.46 Title reveal and transparent item art

User identified the static opening and square/pixel-like item backgrounds. Inspection confirmed opaque/translucent background paint in the original basic and ascension atlases. Four builtin image generations produced two replacement atlases (56 item concepts), four cleanup overrides and a smoother crown emblem. All selected sources copied into assets/art, prompts recorded. Existing transparent rare-material/masterwork art and native vector accessories retained; this is not a claim of 267 separately redrawn assets. Runtime per-object atlas bounds and linear filtering improve item presentation. No raster cleanup by script; read-only alpha/component inspection informed region metadata.

Native boot image now uses the emblem. The in-game splash has a shader-lit dark background, emblem reveal/light sweep/scale, embers and centered typography; Continue skips and timers advance safely. Reduced motion presents the final pose and shorter transition. Actual capture set: four images (three narrow phone screens plus one 56-icon contact sheet). Focused checks loaded all 267 icons and verified Continue plus normal/reduced auto-transition. Title wrapping and atlas fragments were found and corrected during review. See docs/qa/item-splash-0.46-report.md. No balance/save changes, no physical Android verification, and no AAA/SSS completion claim.

## 0.47 Original ornament with clearer page structure

User rejected the flatter redesign after a same-fixture visual comparison and explicitly approved a hybrid. Restored original ornamental panels and dimensional buttons; retained compact horizontal coin header, Equipment/Build/Legacy tabs, full-body equipment view, direct-touch inventory, context-specific scroll memory and larger environment illustrations. Twelve generated inanimate scenes support Stronghold services, professions, relic altar and late-game story/battle locations. Larger battle composition preserves hero sprite poses, static enemy art and existing effects. Frontier nodes, selected talent/relic details, grouped Settings, task thumbnails and corrected merchant denomination labels improve navigation without gameplay/save-schema changes. The 0.46 animated splash is retained.

21 normal/130% phone captures and focused UI actions passed; real-pointer inventory opening, filters, navigation memory, tabs and node selection checked. Existing six-step onboarding pointer regression passed completion/dismissal, saved state and narrow Skip. Old shutdown resource warnings remain. Physical Android performance and long-play pacing remain unverified. Build and verification details: docs/qa/hybrid-visuals-0.47-report.md. No public release, paid service activation or AAA completion claim.

## 0.48 visual trial — Generated fortress floor

User asked to try generated art beneath the interface. Added one portrait charcoal fortress-floor asset through builtin image_gen; exact prompt/source in docs/floor-art-0.48.json. Static aspect-cover TextureRect behind the main shell, 55% opacity over the existing dark base, ignores mouse/touch input. Existing opaque panels, menu, splash, gameplay and saves are unchanged. Three 360×720 captures (Stronghold, inventory, hero) were visually inspected; tests/floor48.gd checked texture load, pointer-ignore and actual navigation input. Historical shutdown warnings persist. Comparison gallery at ignored build/visual-comparison/floor.html. This is a visual trial, not an Android release: existing APK/version remain 0.47; no physical device performance test.

### 0.48 visual trial follow-up — Stone top and bottom bars

User requested the remaining gray upper/lower menu areas receive the same treatment. Reused the generated floor beneath translucent dark header, objective, task and navigation surfaces; fine brass separators and translucent amber active navigation maintain hierarchy. No new raster generation or gameplay/save changes. Four phone captures at 100%/130% text; pointer navigation checks passed (tests/stone_hud48.gd). Visually reviewed Stronghold at both text sizes; original shutdown warnings remain. Comparison: build/visual-comparison/stone-hud.html. Still a project visual trial, not a new APK; 0.47 remains the packaged build.

### 0.48 visual trial — Blackened iron cards

User requested a trial of subtle iron material inside the gray cards. Generated one original blackened-iron texture using builtin image_gen (prompt/source: docs/iron-art-0.48.json). Shared card PanelContainer subclass draws a static inset material behind children; original ornamental nine-slice frames remain untouched. Item tiles add a faint rarity-color pool behind icons. No new rune/symbol decoration. Four phone captures include normal and 130% inventory text; pointer item opening and bottom navigation passed in tests/iron_cards48.gd. Inspected Stronghold and inventory captures. No gameplay or save changes. Prior shutdown resource warnings remain; no physical Android verification. Preview gallery: build/visual-comparison/iron-cards.html. Still a visual trial; packaged APK remains 0.47.

## 0.48 — Stone and iron release

User approved extending the iron treatment to all remaining plain gray interface boxes. Shared StyleBox wrapper now applies the existing generated iron material beneath button/dropdown/input text, popup/modal contents and equipment slots while preserving the original ornamental frames and distinct states. Card subclass no longer draws duplicate texture; item tint remains. Includes the preceding floor and upper/lower stone-bar trials. Game/package version advanced to 0.48.0 (code 48); identity and saves unchanged.

22 phone captures and focused interaction/layout checks passed, including 130% text; existing six-step onboarding pointer regression passed. Menu, inventory/filter, hero, settings, merchant, hunt and Stronghold screenshots inspected. Known exit resource warnings persist; physical Android performance remains unverified. Full verification/package details: docs/qa/stone-iron-0.48-report.md. No balance changes, public publishing or paid-service activation.

### 0.48 follow-up — Hero equipment rail background

User screenshot identified the flat dark strips behind left/right equipment slots. Hero stage now draws the existing generated iron beneath the central portrait, filling those exposed rails with material instead of a plain rectangle. Portrait, slot positions, borders and input remain unchanged. tests/hero_iron_rails.gd captured 100%/130% phone views and opened the weapon slot via real pointer in both sizes; passed. Visually inspected both captures; prior exit warnings remain. Source-only follow-up: the already exported 0.48 APK predates this fix; no replacement APK generated for this small visual correction.

### Hero rail material comparison

User asked to compare stone against iron. Hero stage rail texture is now an injectable Texture2D, default still iron. A nonpersistent preview test overrides it with the existing fortress stone; 100%/130% captures and pointer weapon-slot opening passed. No new generated art, saved setting or APK. Comparison gallery: build/visual-comparison/hero-materials.html. Recommendation: stone for rails/background, iron for individual equipment tiles. This recommendation is not applied as a default without the user's selection.

## 0.48.1 — Selected stone hero rails

User chose stone for the exposed background behind the hero's equipment slots and requested the APK. Set the actual default to fortress-floor-0.48, retaining iron equipment tiles and all prior 0.48 visuals. VersionName 0.48.1/code 49. Focused default-texture assertion, normal/130% rendering and pointer weapon-slot opening passed. No new art, save-schema or gameplay change. Existing shutdown warnings and physical-device verification limitation remain. Package verification: docs/qa/hero-stone-0.48.1-report.md.


## 0.49 — Responsive navigation and discovered masterworks

Measured repeat navigation stalls and retained strong references to shared image/font atlases, including battle backdrops. Removed full battle forecasts from every Explore list row (still available in hunt preparation), throttled dynamic labels and skipped offscreen updates; Bag supplies are paged by 30. Desktop warm Explore construction fell from 309–313ms to 30–33ms, Bag from 128–140ms to 33–34ms. Cold asset loading and physical Android responsiveness remain limitations.

Rat/Hound cards now reference the exact bandaged battle atlas regions. Ten masterwork recipes stay hidden across collection, skills, training, sources, equipment suggestions and direct planners until a super-rare eligible-monster blueprint drop or rare premium merchant purchase. Existing actual ownership/crafting history preserves learned recipes; boss kills alone no longer unlock these ten. Earlier seven guardian relic recipes retain their rules. New optional independent RNG state persists through saves. No visible drop-rate percentages. Ten blueprint item records added (277 total).

Focused discovery/save/merchant checks, 83 essential checks, six-step pointer onboarding and phone UI captures passed. Large text/pagination inspected at 360x800; cards and discoveries inspected at 412x892. Version 0.49.0/code50 exported and v2 signature verified. Known exit warnings persist. No paid service activation/public publishing. Details in docs/qa/responsiveness-blueprints-0.49-report.md.


## 0.50 — The Far Marches, deep builds and restricted card sockets

Implemented the user's approved full expansion solo. Eight heroes,120 enemies/cards,598 items (182 equipment,286 materials),208 recipes,18 story chapters,60 progression contracts,24 hidden masterworks,18 talent nodes/80 points,12 runes and12 optional guardians. Six new regions supply deterministic core equipment, rare optional discoveries, thematic armor sets and progression rewards. Added three distinct hero skills/two paths each, weapon attunements, research-note blueprint restoration, clearer nested farming objectives and return-report upgrade guidance. Depths now rotate threats and retain five-room checkpoints; weekly guardian pool includes the new optional enemies.

All cards declare limited equipment slots; authoritative insertion, filtered UI and free validated old-save migration prevent incompatible attachments without losing cards. UID-based equipment effects survive refinement/tempering and save round trips. No stamina, paid-service activation or public publication. Full English presentation and existing stone/iron UI retained. Thirteen generated art atlases cover new enemies, heroes, battle/work poses, locations, items and12 runestones; art sources and exact prompts recorded.

Verification:83 essentials,30 focused expansion checks, real-pointer six-step onboarding, phone captures412x892/360x800 at130% text,25 targeted prepared-build combat samples and desktop tab timing. One offensive Duskblade sample lost to the final guardian; safe route/Ward relic won, preserving a meaningful defensive choice. No full-campaign balance or physical Android claim. Cold-loading and known harness shutdown warnings remain. Version0.50.0/code51; package/verification details in docs/qa/expansion-0.50-report.md.

## 0.51 — Battle figures, artisan equipment and dungeon journeys

Implemented the requested overhaul solo: 120 mapped enemy figures / 240 poses; floating damage without black plates; scaled creatures, recoil, dodge and eight hero effect paths. Generated eleven atlases with 48 artisan/item icons; edited two enemy sheets to conceal faces. Original prompts/sources recorded in docs/art-provenance-0.51.json. Large-creature clipping found in captures was corrected.

Added per-instance slot-compatible traits, rare crafting outcomes, four tiers each of hammers/knives/mortars, six earned gathering-tool ranks, guardian trophy pools and region-specific secondary supplies. Legendary crafting requires the Blackstar Hammer; guaranteed Legendary refining also requires final-dungeon materials and a high cost. Trait metadata and tools persist through saves/upgrades. Total682 items (242 equipment),232 recipes. Twelve timed dungeon journeys last1-8h with build gates, provisions, stages, recall and single-claim rewards; hero cannot work while travelling. Existing content/saves preserved.

Verification:32 focused checks,83 essentials,30 expansion regressions and phone captures412x892/360x800 at130% text. Fixed a secondary-loot RNG seed issue found by offline/chunk equivalence checks. Actual crafting, all12 journeys, malformed saves, staged dialog refresh and all8 hero effect paths exercised. Version0.51.0/code52 Android debug APK exported and v2 signature verified. No physical Android or full-campaign economy/balance claim; expeditions resolve automatically by preparedness/timer, not separate simulated boss fights. Details/hash/limits: docs/qa/overhaul-0.51-report.md.

## 0.51.1 — Measured battle silhouettes and journey entry repair

Fixed both reported issues. Replaced the uniform enemy atlas grid with measured source bounds and cached UV meshes for all240 poses. Preserved original PNGs, excluded neighboring fragments, kept pose scale/aspect ratio, aligned hero/enemy floor positions and constrained motion inside the arena. Queue miniatures share the corrected enemy renderer. One touching source pair uses a reviewed ownership boundary. Generated no new art.

Reproduced the Dungeon Journeys dead button with real pointer input: the temporary RefCounted helper had been released and its direct-method signal removed. Closure callbacks now retain the helper. Pointer regression passes locked/unlocked entry, preparation, departure and queue review. Rendered/reviewed all10 enemy sheets; inspected ready/attack phone samples at412x892 and360x800 with130% text. Existing shutdown leak warnings persist; no physical-device claim. No economy, rewards, save-schema or progression changes. Version0.51.1/code53; package details in docs/qa/battle-journey-0.51.1-report.md.


## 0.52 — Shattered Realms, 21 rarities and level 130

Implemented the user's expansion request solo. Explore now selects a location and filters its encounters, preserving early hunts for cards without repeating them on unrelated pages. Seven new sequential realms bring totals to190 enemies/cards,946 items (305 equipment,439 materials),329 crafting recipes and46 gathering activities. Twenty campaign locations plus optional areas; twelve existing timed journeys remain separate. New rulers unlock63 equipment recipes and award seals/talent milestones. Regional variants reuse existing measured battle figures.

Seven new professions bring the total to16 skills; their seven material tiers form a connected Forge Seal chain. User explicitly approved raising the cap during the turn: level130, a steep XP tail beyond100, new late gathering/production recipes, region requirements and100 earnable talent points. Twenty-one equipment rarities are attainable by duplicate fusion with escalating gates/costs. Target UID/cards/traits/loadouts persist, protected donor pieces are excluded and the action stays visible in the modal footer. Early catalog definitions and XP thresholds preserved.

Generated nine environment paintings in one atlas; art provenance recorded. Grouped skill navigation, location cards and new page/merchant/forge headers retain approved stone/iron materials.83 essential checks,40 targeted expansion checks, real-pointer onboarding and fusion/navigation checks passed. Nineteen phone captures include130% text and the new-region arena. Seven prepared Warden ruler samples won after excessive unavoidable pressure was tuned; full-campaign/class balance and physical Android remain unverified. Existing harness shutdown warnings persist. No online community service, public publishing, paid-service activation or AAA/SSS quality claim. Version0.52.0/code54; package details in docs/qa/expansion-0.52-report.md.
## 0.53 — Distinct realm monsters, page audit and framed cards

Retained all120 original enemy actor mappings and replaced70 identical realm variants with seven generated regional atlases/140 ready-and-attack poses. Measured alpha bounds and runtime UV meshes keep complete figures separated; battle, queue, Bestiary and cards share each creature. Porcelain faces were corrected to smooth masks. No changes to gameplay rewards, enemy stats or save schema.

Audited43 main-page/dialog phone states and15 focused follow-up states. Streamlined Skills and local-hunt preparation, unified generic world navigation with location selection, added an equipment picker for21-tier fusion plus refinement access, expanded Bestiary/card filters, clarified level-cap XP and realm completion. User then requested prettier card borders and removal of rarity text: all190 card icons now have ornamental frames and subtle scenery; collection rows show slots and ownership, with no visible rarity labels. Five final card captures were reviewed after this correction.

83 essential checks,40 expansion checks,140-pose render inspection and focused real-pointer navigation passed.120 old actor mappings remain identical;70 new pairs are distinct. Existing harness shutdown warnings remain. Physical Android play/performance not verified. Version0.53.0/code55 Android debug package; detailed per-page remaining recommendations, package verification and limitations are in docs/qa/visual-0.53-report.md. No publishing, paid services or AAA/SSS completion claim.


## 0.54 — Live Journey countdown and purposeful progression

Reproduced the reported frozen-looking Journey display: simulation advanced 2.2 seconds while the formatter still showed one hour because it rounded to whole minutes. Added seconds, overall progress and next-chamber countdown. Real pointer tests confirmed ticking labels, stage refresh, completion and collection. All twelve routes now support selectable material/vault/elite paths with offline repetition, chamber histories and recomputed reward validation; legacy in-progress trips retain original payouts.

Connected objectives through all Far Marches and Shattered Realms, moved optional hunts after the main road, added encounter-specific build/upgrade/material planning and collapsed completed tutorial milestones. Added ten combat role patterns across the seventy Realm enemies, seven ruler-card pacts with real tradeoffs, and weapon-attunement milestones at tiers6/11/16. Frontline commissions target known advanced hunts; bounties/contracts/weekly hunts now have progression-relevant rewards, and weekly targets include conquered Realm rulers. Saves, existing art and restricted card slots retained; no drop-rate labels, stamina, paid services or publishing.

Verification:57 focused checks,83 essentials,40 expansion checks,11 phone captures including130% text, real-pointer timer/navigation and16 prepared Warden fights. Final ruler sample took1044s/348 meals. Actual render surfaces measured412x824 and360x720 despite requested taller windows. No physical-device or full-campaign/class balance claim. Existing capture-harness shutdown leak warnings persist. Android debug0.54.0/code56; package/verification details in docs/qa/progression-journeys-0.54-report.md. This implements the six audited areas at the documented scope, not a claim of finished AAA/SSS quality.


## 0.55 — Google test ad placements and optional rewards

User confirmed test ads because production IDs are unavailable. Replaced diagnostic-only delivery with independent format preloading, adaptive management-page banners, natural-break interstitials and explicit food/assistance rewards. Added 10-minute first-display grace, 15-minute fullscreen separation, 3/session and6/day interstitial caps; rewards each3/day with90-second earned cooldown. No ad on splash, tab switch, defeat, recall, onboarding or battle. No cached ad means continue immediately; delayed loads never auto-show. Stronghold and Journey preparation expose optional rewards; assistance now uses a compact hunt selector.

Local pacing persists separately from campaign saves. Campaign IDs and bounded receipts defend against duplicate callbacks/new-save grants and survive legitimate offline dictionary replacement. Fullscreen ads block game input and pause game audio, then recover progress without replacing the reward panel. Official Google demo IDs enforced; production remains blocked. No remote telemetry, billing, paid service activation or publishing.

33 focused ad checks and83 essentials passed. Real pointer reward/no-fill/assistance/Journey-link flows and six phone captures (including130% text) reviewed. Native callbacks simulated only: no connected Android device, so native serving/banner layout/lifecycle/audio remain unverified. Existing11-object/five-resource harness shutdown warnings remain. Version0.55.0/code57; verified signed debug APK. Scope, package hash and remaining live-rollout requirements in docs/qa/admob-0.55-report.md and docs/monetization-boundary.md.


## 0.55.1 — Android banner navigation clearance

Fixed the reported native-navigation overlap at the Android layout layer. A small project-owned bridge reads stable/gesture navigation insets and cutouts, adds8dp separation, subtracts parent-consumed insets and updates before drawing. Godot reserves the same native clearance and waits until the hidden banner has been positioned. Source/build tooling/binary tracked; no change to SDK binaries, ad IDs, pacing, rewards or saves.

Six native geometry checks and35 focused service checks passed. Two narrow-phone simulated layout captures reviewed, with actual Hero pointer navigation and130% text. No physical Android device was connected, so native serving/navigation behavior remains unverified. Debug0.55.1/code58; package and limitations in docs/qa/banner-safe-0.55.1-report.md.
