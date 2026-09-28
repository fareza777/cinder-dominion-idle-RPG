# 0.43 — Expanded world, rare finds and masterworks

## Implemented scope

The roster increases from 42 to **60 enemy definitions**. Existing trial tiers are included in that count; this is not a claim of 60 different species. The 18 new encounters belong to **The Pale Observatory, The Iron Sepulcher and The Ember Rift**, six per region. The first opens after the Unlit Sovereign, then each victory opens the next encounter. Undiscovered enemies remain hidden. Static frontal enemy art uses closed helmets or opaque veils without visible facial anatomy.

Each region has three two-encounter objectives with one-time currency/shard rewards. Four new story chapters bring the total to eleven. The journey guide now continues through the seven optional guardians and the new regions. Total content: **267 items, 181 activities, 60 cards, 60 unique rare materials and ten new craftable masterworks**. Activities include hunting/crafting/gathering; they are not 181 story quests.

## Stamina and saved progress

Stamina has been removed: no reserve, drain, regeneration, waiting screen or stamina-imposed hunt limit. Food, survival, queue limits and existing rewarded queue assistance still apply. This supersedes the historical 0.41 and 0.42 stamina behavior.

Migration removes obsolete stamina fields and maps old combat XP to the same level and fractional progress under the new curve. Levels remain capped at 100. The old numeric wallet field is retained and interpreted as Silver; it is not multiplied. Revised prices therefore change purchasing power. Existing gear, cards and kill records are retained. NPC stock already saved under old pricing remains valid until its next refresh. Package identity and save folder remain unchanged.

## Economy and progression

- 1,000 Silver = 1 Gold; 1,000 Gold = 1 Platinum. Display is exact, with no rounding loss or conversion button.
- Bladecraft, Might and Warding use `25*(level-1)^2 + 4*max(0,level-20)^3` total XP. Level 100 needs 2,293,025 XP. Professions retain their existing 245,025-XP curve.
- Ash Rat gives 5 Silver and 6 total melee XP before route modifiers, including 2 Bladecraft XP. Its currency no longer scales with the player's level. A normal 1,000-win batch yielded exactly 5,000 Silver in the focused test.
- From an exact level boundary, rats require about 13 wins for level 1→2, 490 for 20→21, 6,820 for 50→51, 20,345 for 75→76 and 40,385 for 99→100 Bladecraft. These are XP calculations, not measured completion times.
- Frontier base rewards range from 80 Gold to 250 Gold per victory, with stronger defenses, pressure and preparation requirements. Mastery/fortune reward bonuses are percentages rather than flat additions that disproportionately enrich weak enemies.
- Workshop coin costs rise by metal and quality, reaching 1.8 Platinum for the final Dawnsteel refinement. Relic ranks from 10 add increasing coin fees alongside existing materials. Guardian tempering adds a quality-scaled fee.
- Merchant provisions are repeatable: 20 regional meals for 2.5/7.5/20 Gold according to progress. Gathering/cooking remains available. Masterwork Commissions cost 1 Platinum each and are consumed by recipes; they are not real-money purchases.

Additional denominations beyond Platinum are not needed for current authored prices. Denomination names alone do not control inflation: encounter rewards, equipment costs and recurring meal demand do that. Long-term surplus after completing finite content remains possible and is not claimed solved indefinitely.

## Rare hunting and equipment

Every enemy has its own material and a generated inventory icon. All 60 materials are used by at least one masterwork recipe. Per-victory probabilities are 0.010% for starting enemies, 0.030% for regional enemies, 0.080% for trials, 0.150% for Apex, 0.200% for Depths and 0.300% for guardians/frontiers. These independent rolls have no pity counter or guaranteed kill threshold. They use a separate persisted RNG and do not advance combat or card RNG. Card/material quantity bonuses do not increase these rare-material odds.

Old enemies therefore retain collection/crafting value without becoming efficient late-game leveling targets. Material sources and odds appear in hunt preparation, bestiary and source views. Random finds are not treated as guaranteed inputs by the craft planner. Rare materials and commissions are protected from ordinary selling.

Ten masterworks have guaranteed Legendary quality, one equipment card socket and distinct implemented effects:

| Item | Slot | Unique effect |
|---|---|---|
| Ashwake | Weapon | Ignores 10% of boss armor |
| Oathkeeper | Shield | Reduces every third boss strike by 10% |
| Lastlight | Necklace | Meals heal 10% more |
| Starless Visage | Head | Shock duration reduced by 50% |
| Cinderbound Mantle | Body | Damage-over-time damage reduced by 25%, rounded up |
| Grasp of Ruin | Hands | Special attacks deal 8% more damage |
| Gravetread | Feet | First three enemy strikes deal 15% less damage |
| Keeper of the Last Light | Belt | Meals heal 15% more at 40% HP or below |
| Ember Oath | Ring | 8% more boss damage; take 5% more direct damage |
| Pale Covenant | Ring | 6% more damage against Chilled or Weakened enemies |

Recipes require Smithing 90–100, one to four commissions, Dawnsteel, guardian cores and several unique finds. The first three masterworks and helmet only require old-world finds. Later recipes use consecutive groups of three frontier enemies; no early-region aid requires the final region's boss material. The last ring is a post-final-boss reward for further farming and collection.

Cards now have 60 distinct profiles, including conditional status damage, trade-offs, roles and clearer descriptions. Drop rates remain 0.020%–0.002%; the 18 new cards are Mythic at 0.002%. Their art uses their corresponding new enemy portrait. Existing duplicate-card restrictions and outgoing bonus caps remain. Extremely rare drops are optional long-term goals, not guarantees after 1,000 kills.

## Art and phone review

Six selected new atlases cover three coin denominations, all 60 materials, ten masterworks/commission and eighteen enemy portraits. Sources, generation prompts and the selected facial-concealment revision are recorded in `docs/currency-art-0.43.json` and `docs/frontier-masterwork-art-0.43.json`. Runtime atlas regions provide icons; no Python raster editing was used. New regions use the new portraits within existing page scenery rather than three separate environment paintings.

Seven rendered **360×720** views at **130% text** were reviewed: wallet, recipe, masterwork list, frontier, card, merchant and hunt rewards. Screenshots are in `docs/qa/screenshots/*-0.43.png`. Long panels scroll; text stayed within panels. The wallet stacks denominations to fit the header. An old double-encoded separator in trial enemy/card names was corrected and the affected capture regenerated.

## Actual verification

- `tests/essential_checks.gd`: 83 essential checks passed (`build/essential43.log`).
- `tests/economy43.gd`: passed content/source coverage, exact denominations, old-save migration and repeat-load stability, old merchant stock, 1,000 uninterrupted rat victories, a real rare-material success at authored odds without disturbing other RNGs, crafting all ten Legendary pieces, commission/provision charges and sale protection, frontier unlock/claim-once/save, final story gate, and whole-versus-chunked offline equivalence. Seven phone captures completed.
- `tests/balance43.gd`: 30 bounded encounters, five classes with two build configurations against first/middle/final frontier targets. 19 wins. Standard max-level equipment without cards could open the first region for four classes but failed middle/final targets. Fully prepared masterwork/card configurations won all selected targets. Final fights ranged from 170–400 seconds and consumed 42–105 meals in those fixtures.
- `tests/frontier_routes43.gd`: Warden won 18/18 sequential frontier encounters using only equipment whose material sources were available before each encounter. This assumes the rare materials/cards had already been farmed; it does not measure acquisition time.
- Source review confirmed new enemy portraits use the shared battle texture path. Card profile audit found no identical complete profiles. `git diff --check` passed before packaging.

These are bounded fixtures, not a full campaign playthrough. All-class sequential routes, rare-drop acquisition pacing, merchant affordability throughout a real save and long-term inflation still need player feedback. Historical ObjectDB/resource shutdown warnings remain unresolved. No physical Android installation, upgrade or performance check was performed. No paid services were activated and nothing was published. This is not a finished AAA/SSS quality claim.

## Android artifact

Export reported `[DONE] export`. APK: `build/android/cinder-dominion-0.43.apk`, **240,568,924 bytes**. Android package inspection confirms `com.ashencovenant.prototype`, versionCode **43**, versionName **0.43.0**, label **Cinder Dominion: Idle RPG**, and **arm64-v8a/x86_64**. APK Signature Scheme v2 verification succeeded.

SHA256: `2CF8EE27EECA3B3CE377212BAB40AC734842995D4A18B2C0277B3049AF7B337C`.

The known console wrapper remained after its export child exited. Only the verified export wrapper PID 15184 was stopped after artifact verification; a normal wrapper exit code is not claimed. Existing duplicate UID warnings concern the ignored build/admob source copy. Tests, docs and build sources remain excluded from the APK. Physical installation/upgrade remains untested.
