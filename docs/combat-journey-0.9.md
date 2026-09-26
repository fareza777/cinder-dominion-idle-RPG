# Combat & journey polish — 0.9

## Character presentation

The existing portrait artwork now uses anticipation before the combat timer resolves, a directional lunge and small rotation on attacks, recoil on hits, an evasive lean on misses, breathing, guardian entrance movement, healing rings and an awakening wave. Attacker motion is no longer inferred from the defender's damage flash. Enemy misses and actual food recovery emit presentation events. Phase transitions do not masquerade as ordinary hits.

These effects consume simulation events and do not change damage or rewards. Stale offline events are filtered. Hidden arenas skip animation work; the battery option caps redraw at 30 fps. Reduced motion disables positional movement, rotation, attack trails and expanding waves while retaining static healing feedback and combat text. Assets remain illustrated portraits, not newly rigged skeletal characters.

## Hunt decisions

Enemy preparation now links to a 5/15/30-minute planning view. It converts an estimated duration into a fixed fight count, shows expected food, strongest hit and conditional guaranteed rewards, and offers one-fight preparation, food crafting and loadouts. Blocked targets/current queues cannot start the plan. Stalled damage cannot start a long hunt from this screen.

The forecast budgets one health buffer across the entire consecutive hunt. It is still an estimate: misses, crits, potions, mitigation changes, food overflow and fight-to-fight variation affect actual results. Random equipment and first-clear bonuses are excluded from the displayed reward estimate.

Return after this fight opens a clear confirmation, keeps the current battle unchanged, converts the current order to end after its next victory and cancels waiting tasks. Defeat still ends the hunt. Normal save and offline logic preserve the choice without a new required save field.

## English writing

The three-scene opening now follows the valley's loss, Cinderwatch's survivors and the player's decision to leave shelter. Onboarding, exploration and trial copy received focused revisions. Practical directions remain explicit rather than being replaced with vague lore. This is a targeted editorial pass, not a claim that every string has been professionally localized or voice acted.

## Scope and verification

50 essential checks passed, including four focused additions covering finish-after-fight behavior, save/offline equivalence, rejection while idle and cumulative food estimates. Seven phone-sized captures cover the planner, confirmation, awakening, dodge, reduced motion, risk and opening narrative. UI capture invokes the real planner and confirmation buttons. Screenshots show rendered states; they are not a substitute for animation playtesting on Android.

Android debug export is provided for user playtest. No physical-device performance or long-duration balancing was performed this iteration. No monetization or publishing changes.
