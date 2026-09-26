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
