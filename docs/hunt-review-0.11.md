# Hunt review — 0.11

## Player flow

Refuge now links to the latest closed hunt. Hunt reports shows one selected order instead of twelve expanded cards. A compact recent-order list lets players inspect another hunt. The selected report shows duration, victories, supply use, rewards, restocking actions and links to equipment upgrades or the next objective.

Completed hunts with at least one win show seconds and meals per victory. Comparison searches older completed orders for the same enemy. In-progress, recalled and defeated orders remain visible but are excluded from completed-run averages because unfinished fights can distort them. The UI explains that food, starting health, builds and randomness affect comparisons; it does not claim the latest build caused an improvement.

New orders record exact food and potion consumption by item ID. Restock opens the existing crafting planner for the consumed amount, including missing materials. It adds nothing for free and does not automatically start a task. Repeat opens the duration-based hunt planner. Rewards are displayed as already received.

## Save compatibility

The optional consumed map is present only on newly started orders. Older reports and older active orders remain without item-level tracking; they retain their aggregate totals and display an explicit explanation. Validation requires known food/potion IDs, nonnegative integer counts and category totals equal to reported meals/potions. Existing save schema remains unchanged.

## Verification and limits

54 essential checks passed. Three additions cover exact food consumption, invalid consumption rejection and normalized comparison filtering. Seven isolated phone captures cover empty, comparison, restock, repeat, defeat, legacy and large-text views. Actual restock and repeat buttons were invoked. The capture error log is empty.

APK remains debug signed for playtesting. No physical Android installation, long-term balancing or monetization changes were performed. This iteration improves the result-to-preparation flow; it does not add new enemies or claim finished AAA production.
