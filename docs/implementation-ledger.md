# Execution ledger — plan: docs/superpowers/plans/2026-09-25-ashen-covenant-foundation.md

User approved implementation, chose solo execution, and explicitly reduced testing on 2026-09-25.

Ruling: user-requested light checks supersede exhaustive TDD and reviewer agents. Cost: broad gameplay balancing and device coverage remain for user playtest.

Preflight: content -> state -> transactions -> queue -> combat -> save -> presentation have shared dictionary contracts. Use compact domain modules with centralized state mutation, bounded step-based catch-up, and native Godot controls. All domain event timers use simulation time. Visual effects never supply rewards.

Status: playable foundation implemented on feat/ashen-foundation; debug APK exported. No gameplay code existed at baseline.

Implemented: catalog, centralized model commands, production reservation/refund, queue targets, melee combat and progression, tutorial/unlocks, equipment and presets, save checksum/rotation, 24-hour catch-up, five screens, art/audio and Android export.

Implementation decisions: compact `game/model.gd` and `game/save_store.gd` replace the larger planned module tree. UI uses reusable native controls from `ui/style.gd` and `ui/pages.gd`. Domain state is centrally mutated, not immutable copies. English uses paired strings and remains incomplete instead of shipping complete CSV localization. Save schema v1 is validated; no legacy migration exists because there was no previous released schema. New fights begin immediately after a victory, with their first attack delayed by the combat timer. Presentation uses animated embers and portraits, not skeletal actors. These are explicit foundation limitations, not claims of full design completion.

Verification policy: nine meaningful domain checks, engine import/startup, visual captures and Android installation/startup only. Full stress/device matrices and balance playtests deferred per user direction. Asset manifest and README describe the delivered build and remaining milestones.
