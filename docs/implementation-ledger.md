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
