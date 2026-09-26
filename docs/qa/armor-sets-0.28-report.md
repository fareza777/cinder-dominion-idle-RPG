# Build 0.28 — armor identity and loadout comparison

## Delivered
Two equipped armor pieces activate one metal identity. Shields/head/body/hands/feet count; swords and tools do not. Steel reduces every third incoming hit by 15%; Moonsteel reduces enemy healing by 20% after the rune multiplier; Dusksteel increases fourth-hit damage by 15%; Dawnsteel adds 8 food healing strength, with actual healing still capped by missing HP. Two different sets can coexist; more than two pieces of a metal do not increase its bonus.

Effects are derived from equipped IDs, so existing gear, saves and saved loadouts participate without new state fields or renamed IDs. This intentionally buffs existing advanced builds. Shared combat functions feed both simulation and forecast. Character, Ascension and equipment detail expose effects and before/after set summaries. Numeric auto-equip is described as base-stat selection; it does not optimize set synergy.

New loadout comparison clones state, removes active fight/potion buffs for a fair outside-combat comparison, applies the saved loadout on the clone, then forecasts an unlocked encounter. Viewing does not mutate equipment or consume supplies. Applying remains explicit and blocked during combat. Displayed advice is a snapshot when opened and remains an estimate.

## Actual verification
- Godot import completed without script errors; all 83 existing essential checks passed.
- Focused set checks cover activation threshold, excluded weapon/tool slots, all four combat effects, set removal when swapping armor, save encode/decode, and non-mutating loadout preview.
- Four prepared level-100 builds fought the Lantern Widow once using the same starting RNG. Each used Rare Dawnsteel core equipment plus Common gloves/boots of the tested metal. All won. Steel forecast 110s / 5 meals, actual 5 meals; Moonsteel forecast 102s / 5 meals, actual 6; Dusksteel forecast 102s / 5 meals, actual 6; Dawnsteel forecast 110s / 5 meals, actual 6. The core equipment also enables Daybreak. This fixture demonstrates functioning trade-offs, not universal superiority or complete balance.
- Every sweep fight produced identical normalized saved state after one 600-second advance versus sixty 10-second advances. The first test compared raw in-memory dictionaries against JSON-loaded dictionaries and failed on representation differences; corrected the comparison to normalize both through the same save codec, then reran successfully. No combat fix was inferred from that test-only mismatch.
- Six runtime captures reviewed, including 360x800 at 130% text. Equipment detail, set collection, comparison cards and apply/plan controls remain readable and scrollable. Captures repeated after copy refinements; final error log empty.
- Android debug APK exported, signed and verified. Package com.ashencovenant.prototype, versionCode 28, versionName 0.28.0; arm64-v8a and x86_64.

## Limitations
No physical Android test, full encounter/doctrine/quality balance matrix, natural-play pacing measurement or new art/audio. Existing generic armor icons remain. Two-piece sets add equipment identity; individual unique-item effects, talent milestones and the rest of the audit remain on the delivery roadmap. View-only forecast strips temporary potion buffs and uses present HP/stock; it cannot guarantee a win. No user save files were changed by the fixtures.

APK: build/android/ashen-covenant-0.28.apk

Bytes: 89542798

SHA256: B795CD0DC4C85A9740A2BCD484A880AA099F0981B1DBA19346C6ADEE6707AE22
