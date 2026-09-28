# 0.44 — Less text, clearer hunting

## Shipped changes

- Removed numeric drop probabilities from monster card detail, hunt preparation, rare-material descriptions and sources. Removed old expedition equipment/relic probability copy and guidance that told players to check odds. Internal probabilities, rewards and rarity labels are unchanged. Historical design/QA documents retain their technical figures; they are excluded from the APK.
- Hunt preparation leads with portrait, stats, short danger/time/meal estimate, coins/XP and equipped food. Enemy mechanics, status type, loot, first-clear rewards, mastery and forecast limitations remain accessible under **Show enemy & loot details**. **Begin** stays in the dialog footer. No ability or item-effect percentages were hidden: those matter when comparing builds.
- Card screens retain art, rarity, role, actual effects/trade-offs, owned quantity and actions. Removed repetitive slogans, build-hint paraphrases and long probability explanations. Socket/extraction and irreversible-sale guidance remain.
- Crafting mastery is optional detail. Missing materials show their counts beside Find; the duplicate auto-craft action is removed when ingredients are missing, leaving the footer's planning action. Output and error copy is shorter.
- Masterworks pair 72px item art with titles instead of stacking a large icon above each name. Recipe requirements and unique effects remain readable.
- Bestiary now shows eight entries per page and supports all three frontier region filters. Rows lead with portrait, name, wins/mastery and ordinary loot; Inspect & hunt opens full preparation details. Discovery rules remain unchanged.
- Shortened wallet, merchant, frontier and expedition introductions. Fixed repeated “per victory,” singular win wording, and updated About's stale world counts. Searched runtime source/data for the previously found broken encoding and common requested spelling errors; none remained in that scan.
- Opening a new modal hides the preceding toast. This fixes stale “Task queued” banners obscuring card, recipe and bestiary content during navigation.

No new generated art, drop-rate changes, combat balance changes, save-schema changes or paid integrations. Changes reuse existing fonts, frames and art.

## Verification performed

`tests/copy44.gd` passed. The actual detail toggle expands/collapses, the Begin signal starts a fight, bestiary paging moves forward/back, and the Ember Rift filter displays six entries without a Next page. Six rendered 360×720 captures at 130% text were reviewed: compact hunt, expanded hunt, card, masterworks, bestiary and crafting. Final captures are in `docs/qa/screenshots/*-0.44.png`. Screens were recaptured after correcting stale-toast obstruction and reducing duplicate crafting copy. No overlapping text observed in those views; long details scroll.

Godot import completed without parser errors. Runtime probability-disclosure search leaves no card/material drop-rate copy; one generic hunt-report note about statistical variation remains. `git diff --check` passed. Content JSON is unchanged. Only focused UI verification was run; the full combat suite was not repeated for copy/layout changes. Historical shutdown warnings (11 ObjectDB instances/five resources) remain. No physical Android testing and no claim that every deep dialog at every font size has been visually reviewed.

## Recommended next improvements — not implemented here

1. **Favorite hunts:** let players pin a few repeat farms with their food, quantity and loadout choices. There are now 60 enemy definitions; repeated navigation will matter more than another explanatory paragraph. Preserve manual queue limits and rewarded assistance rules.
2. **Masterwork tracking:** extend the existing tracked-upgrade feature with a direct Track action on masterwork recipes and source links beside each missing rare material. Show owned/required counts and the next useful hunt without displaying odds or promising a guaranteed drop.
3. **Navigation memory:** returning from a card, item or source should restore the previous page, filter and scroll position. Current card and masterwork Back actions can reopen the first page, making repeated comparisons cumbersome.
4. **Contextual help:** continue moving repeated teaching copy into short optional help while preserving required material counts, combat risks and irreversible-action confirmations. Prioritize equipment/socket management and the late-game service menus in the next visual pass.

## Android artifact

Export reported `[DONE] export`. `build/android/cinder-dominion-0.44.apk`: 240,568,516 bytes. Package inspection confirmed com.ashencovenant.prototype, versionCode 44/versionName 0.44.0, Cinder Dominion: Idle RPG, arm64-v8a/x86_64. APK v2 signature verification passed.

SHA256: `286DA5C8E929BD76F4ED5FA40DCC87E9DD0BDFB70F1629603689649CEBB284EB`.

The export child finished but the known console wrapper remained; verified wrapper PID 5856 was stopped after artifact verification. No normal wrapper exit code is claimed. Existing duplicate UID warnings refer to ignored build/admob sources. Physical installation/upgrade was not tested.
