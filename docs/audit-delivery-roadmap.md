# Audit delivery tracker

User approved the complete audit direction on 2026-09-26: work solo, preserve saves, full English, meaningful limited checks. This tracker retains the full scope across autonomous iterations. Do not describe a partial batch as the entire audit completed.

## 0.27 implemented
- Persistent optional upgrade goal, Refuge entry, crafting/training/equip/hunt actions.
- Four advanced ingot work orders and selected-food order using real dependency planner.
- Training selects available XP/time candidates including material preparation.
- Apex victories count toward regional Runeforge progress from existing saved kills.
- Three optional combat doctrines at Bladecraft 25, shared combat/forecast rules, saved with loadouts.
- Tier-relevant bounty rewards and mining/cooking shortcuts.
- Inventory sort/slot filters and 30-entry equipment pages.
- Hunt readiness checklist and compact Ascension banner.
- Bestiary with region selection, drops, tactics and hunt planning.
- Four-pose sprite atlas for hero and three regional archetypes; Apex retains unique portrait art.
- Four original music tracks encoded as Ogg; WAV sources retained outside export.
- Time-budgeted offline catch-up, responsive progress screen, simulate on copy then commit, keyboard/back guard.

## Still required to fulfill the broader audit
1. Expand character animation beyond four sprite poses: layered rig, guard/death/victory and unique Apex motions; additional original icons and layered arenas. Current atlas is not a skeletal rig.
2. Deeper equipment identity and talent milestone progression; compare multiple viable builds and balance doctrines using measured encounter results.
3. Measure natural/automated milestone pacing from a new save. Previous 40–80 hour completion estimate remains unvalidated. Version 0.29 adds duration-limited training batches with dependency supplies; these do not adapt recipes during execution or automatically restart.
4. Daily task choices and optional weekly hunt variety, preserving carry-over. Do not add punitive streaks or mandatory ads.
5. Audio buses, richer musical variation/material SFX, actual listening review. Ogg conversion preserves existing score, not a new composition.
6. Benchmark physical Android lifecycle, frame time, memory, battery and cold launch. Catch-up is responsive but total simulation cost has not been eliminated.
7. Incremental UI controller separation, catalog validation tooling, explicit migration chain before any schema/ID changes. Optional 0.27 fields are backward compatible; this is not a general migration framework.
8. Loadout forecast comparison, opt-in queue notifications and cloud save conflict design only where useful. Store release/commerce requires a separate implementation and verification stage; current providers remain disabled.

Keep finished changes reviewable and versioned. No publishing, paid service activation, or claims of finished AAA/SSS quality. Read this tracker and implementation ledger in subsequent development runs.

## 0.28 delivered
Four two-piece armor identities integrated into the shared combat/forecast rules: Steel special-hit defense, Moonsteel enemy-healing suppression, Dusksteel fourth-hit damage and Dawnsteel food strength. Mix two sets across five armor slots; weapons/tools excluded, no higher-piece scaling. Existing equipment gains these identities without save changes. Hero, Ascension and item comparisons expose effects. New read-only loadout comparison targets an unlocked encounter and offers explicit apply/plan actions. Numeric auto-equip is labeled as such. A four-build single-encounter sweep and chunk equivalence passed; broad balance, unique individual item effects and talent milestones remain open.

## 0.29 delivered

Training plans now accept target level and 15/60/240-minute limits for six noncombat skills. Preview includes dependency XP, time, queue steps and projected level; a saved goal allows continuation after the batch. One available recipe runs for up to 1,000 cycles, with the next batch reconsidering unlocked recipes and current stock. Existing queues cannot be overwritten. First-save Smithing fixture reaches level 7 with 1,054 XP in a nominal 884-second batch. This is a bounded simulation check, not measured full-campaign pacing or a fully adaptive training loop.

## 0.31 delivered

Small animated task-bar thumbnail with 24 new work poses across six skills; battle thumbnail reuses existing art. Hero equipment now uses a full-body base illustration with six interactive anatomical slots, plus tool routes. These are four-pose work animations and a fixed base hero portrait, not a layered skeletal rig or equipment-driven body appearance. Remaining animation, icon, balance and device priorities still apply.

## 0.32 delivered

Three free classes, named journeys, attributes and class skill milestones added alongside progressive enemy discovery and distinct generated character/work art. Native AdMob demo controls are available; production consent, serving/device verification, monetized entitlements and long-term class balance remain open. See docs/qa/characters-discovery-0.32-report.md. Earlier audit priorities remain pending.

## 0.33 delivered

Visual direction revised at user request: concealed faces across runtime art, including enemies/statues/legacy fallbacks. Reaver and Apothecary expand the free roster to five with shared forecast/runtime effects. Broad balance, native device checks and production monetization remain open. See docs/qa/faceless-roster-0.33-report.md.

## 0.34 delivered

Optional-guardian and build-depth package: seven unique gear effects with first-clear blueprints and deterministic acquisition fallback, four socket relics, ten class paths, three socket unlock milestones, tempering, target farming/routes, Depths and mastery yield. Rewarded-only adaptive queue assistance uses the native demo callback, no free grant or production activation. Added player-chosen carry-over contracts and a rotating weekly guardian target. Broad but bounded five-class difficulty sweep now establishes a rising late-game ceiling; 45 selected-counter/seed checks pass while unchanged strong builds fail deeper fights. It is not a fresh-save pacing/retention study or exhaustive build proof. Continue physical Android/consent/serving, shutdown cleanup, full progression economy, richer weekly mechanics and remaining audio/animation/controller priorities. See docs/qa/endgame-0.34-report.md.
