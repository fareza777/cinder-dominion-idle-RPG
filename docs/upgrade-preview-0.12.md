# Upgrade preview — 0.12

Workshop now previews a one-quality refinement using isolated copies of the player's state. It shows total attack and armor, selects among unlocked enemies, and compares shared combat forecasts for fight duration, meals and strongest enemy hit. Enemy recovery stalls are described explicitly instead of displaying a meaningless duration. Estimates remain conditional on current health, build, supplies and combat randomness.

For unequipped equipment, the preview assumes the refined piece replaces the current piece in that slot. The UI states this clearly; refinement does not silently equip bagged equipment. Equipped items still follow the upgrade through existing reference updates.

Cost is visible before the detailed preview. Missing gold/scraps link to contracts, unlocked field records and spare gear in Bag; missing ingots and Smithing levels retain working planner/training links. No sale, salvage, equip or refinement action happens merely by opening a preview. Above-cap equipment shows its real contribution without a misleading downgrade arrow.

Validation: 57 essential checks passed, including three additions for preview purity, agreement with a real refinement, and rejection of above-cap previews. Four isolated phone captures show missing materials, completed refinement, bagged equipment and large text. The actual refine button was invoked. UI capture error log empty. Android debug export provided for user testing; no physical-device or long-duration balance testing this round.
