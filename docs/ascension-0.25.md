# 0.25 — Ascension

## Player loop
Train gathering and Smithing, gather tier materials, forge and equip a stronger build, prepare higher-healing food, then challenge a new Apex route. Repeated hunts feed relic progression, advanced ore stocks and occasional matching-tier equipment drops. New one-time contracts reward crafting, material gathering and first victories. Journey guides the player through the nine Apex objectives after the existing trials.

## Content totals
| System | 0.24 | 0.25 |
|---|---:|---:|
| Item definitions | 40 | 96 |
| Equipment | 20 | 56 |
| Materials | 14 | 30 |
| Food | 3 | 7 |
| Potions | 3 | 3 |
| Gathering activities | 7 | 19 |
| Crafting recipes | 20 | 64 |
| Enemy encounters | 25 | 34 |
| Total activities | 52 | 117 |
| Journey objectives | 30 | 39 |
| Contracts | 8 | 25 |

Nine skills retain level cap 100. Existing daily bounties, talents, relics, runes, loadouts and story chapters are unchanged. Hunt Mastery automatically covers all 34 enemies, giving 136 rank milestones.

## Crafting bands
Steel starts at level 25, Moonsteel at 45, Dusksteel at 65, Dawnsteel at 85. Each adds six combat equipment pieces, three tools, ore, ingot, log, raw fish and cooked fish. The final cuirass requires Smithing 100. Gathering reaches 85; cooking 90; tools 95. Alchemy was not expanded in this release.

Common swords grant 12/20/30/42 base attack. Cooked fish restore 50/65/80/95 HP before relic bonuses and the HP cap. Tool speed bonuses are 15/20/25/30 percent, subject to existing total speed limits. Higher-tier refinement uses the matching ingot and larger gold/scrap costs; the Legendary limit is unchanged. Gear drops do not have a new equip-level restriction.

## Apex encounters
Three sequential optional encounters follow each regional Guardian Trial, nine total. Each uses a generated portrait and declared third-strike parameters: attack multiplier, retained armor fraction and recovery fraction. The shared combat helper feeds both actual damage and forecasts. Each special has an English name and numerical explanation. No alternate simulator or new hidden status mechanics.

These encounters drop Moonsteel, Dusksteel or Dawnsteel ore, relic fragments and the existing 5% equipment chance with an advanced metal pool. First-clear scraps/meals follow the existing regional rule. Separate contracts grant a one-time reward; rewards cannot be claimed twice.

## Presentation and compatibility
Ascension paths is reachable through Skills and Explore, with four illustrated tier tabs, explicit prerequisites, Train buttons and existing supply-planner actions. Available/All recipes prevents the expanded catalog from flooding the opening Skills view. Equipment, supply planning, item art, refining, battle portraits and forecasts use the same catalog.

Three original generated atlas files provide 29 paintings: nine portraits, sixteen inventory objects and four places. Runtime AtlasTexture regions consume them without modifying the generated originals. Armor/tools/food/logs reuse appropriate existing category artwork; no claim of unique art for all 96 items. Prompts and provenance are in ascension-art-0.25.json.

All pre-existing item, skill, activity and enemy definitions were compared with the preceding commit and remain identical. Existing IDs, save schema and player files are preserved. New content can change late-game equipment choices and economy; this is not a claim that balance is final.

## Remaining work
Long-duration progression pacing and all nine Apex encounters need player balancing feedback. The six automated checks target supply-chain integrity, real crafting, matching-metal refinement, save validity, deterministic combat and one prepared endgame victory. The first two material bands and every combat build have not received a full natural-play run. Physical Android performance, audio listening and device controls remain unverified. Existing audio and onboarding are retained. SSS is a direction, not a completed quality certification.
