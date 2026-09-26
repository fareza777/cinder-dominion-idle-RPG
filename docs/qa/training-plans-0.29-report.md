# Training plans — 0.29

## Delivered

Six noncombat skills support a target level up to 100 and a batch time limit of 15 minutes, 1 hour or 4 hours. The planner considers currently unlocked recipes, includes missing-material collection and intermediate crafting, and selects by target-skill XP per total estimated time. Intermediate steps in the same skill contribute to projected XP and level. Up to 1,000 final-recipe cycles and 20 queue steps are allowed.

The start action recalculates from current state. Existing work is never overwritten. A saved training goal appears in Skills and remains after the batch; reopening considers current stock and newly unlocked recipes. Stopping tracking keeps queued work. Optional save field `training_goal` retains schema 1 and does not reset old saves.

## Verification performed

- Godot 4.7.1 import and Android debug export completed.
- Existing 83 essential checks passed. The final batch-search refinement was covered by the targeted training script afterward.
- `tests/training29.gd` passed: short level target counts dependency XP; preview does not mutate source state; bounded batch; existing queue preservation; save round trip; actual XP/level versus preview; persistent goal; clearing tracking; invalid skill rejection; maximum-level completion; one-hour whole versus 360 ten-second chunks produce equivalent normalized saves.
- Fresh Smithing fixture: Copper Sword x34, nominal 884 seconds including supplies, +1,054 Smithing XP, level 1 to 7. A later batch selected Copper Gauntlets with projected level 16. This demonstrates continuation, not campaign completion time.
- Five captures from `tests/capture29.gd`: first plan, existing work, saved goal, next batch and narrow layout. The script activates the real start-button signal and asserts queue and goal creation.
- Visually reviewed 480x960 layouts and 360x800 at 130% text. Narrow duration-button overflow was found and fixed with shorter labels; final capture error log was empty. Body content scrolls independently of the fixed primary action.
- Two implementation defects caught and corrected: duration preview lazily mutated progression defaults (preview now clones the model); JSON integer-valued floats failed membership in duration constants (validated then cast to integer).

## Artifact

- APK: `build/android/ashen-covenant-0.29.apk`
- Package: `com.ashencovenant.prototype`, version code 29, version name 0.29.0; verified using aapt.
- Size: 89,547,180 bytes.
- SHA-256: `E139C3B12B91E85EB1061C471EE80A076D614A5AD82BB85C395168E67A1C2191`.

## Limits and remaining work

Time uses current bonuses; mastery may shorten execution. The 1,000-cycle cap can produce a batch substantially shorter than the chosen time limit. Newly unlocked recipes are considered when the next batch is planned, not during execution. Training does not restart automatically. Combat skills use their existing hunt progression. Candidate selection optimizes training XP per estimated time, not equipment value or material resale value.

No physical Android installation, lifecycle, battery or touch playtest was performed. No new art or audio in this iteration. Full campaign pacing, broad economy balance and the remaining audit roadmap are still open; this build is not a finished AAA/SSS release.
