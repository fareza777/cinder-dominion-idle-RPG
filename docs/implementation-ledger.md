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
