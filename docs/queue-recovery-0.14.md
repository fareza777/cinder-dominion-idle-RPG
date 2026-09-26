# Queue recovery — 0.14

Blocked non-combat production can now preview and prepend material dependencies while retaining the original task, completed counters and waiting tasks. The existing recursive planner supplies dependency recipes from current stock. Only dependency steps are inserted; the original final production step is not duplicated.

Preparation covers at most 100 remaining production cycles, with explicit disclosure that longer orders may need another preparation batch. Level-target orders estimate remaining cycles from recipe XP. Combat, active work, missing skill unlocks, unsupported ingredient sources and capacity above 20 slots fail without partial queue edits. Execution recomputes the plan, and the UI guards stale task actions before cancelling, moving or preparing a different task.

The queue UI distinguishes running, waiting for requirements and queued tasks, shows progress bars and correct units, and provides a manual refresh. It is a snapshot, explicitly labeled as such. Empty queues link to work orders or the current objective.

Smithing level-ten guidance previously computed a total above the crafting planner's 100-item cap. The total remains visible, but both recommendation and Journey action now request a supported batch.

Verification: 64 essential checks passed, including four added checks for read-only exact dependency planning, preserved counters/following tasks with offline equivalence, atomic capacity rejection and valid long-goal batches. Five isolated phone captures cover empty, blocked, preparation, resumed and large-text queue states. The real preparation button inserts gathering before the original production task. Android debug export is for user playtest; no physical-device testing or new monetization.
