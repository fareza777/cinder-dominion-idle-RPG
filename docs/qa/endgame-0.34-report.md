# 0.34 — Optional guardians, rewarded assistance and difficulty audit

## Delivered

Seven sequential optional guardian locations, each with a generated concealed-face portrait, combat profile and unique equipment reward. The first is revealed after the final Crown Apex encounter; each victory reveals the next. First clears grant a blueprint and three cores total. Repeats grant one core; every clear grants two Dread Seals and an 8% unique drop roll. After eight victories against that specific guardian, 16 seals buy its named relic. Blueprints unlock two-stage recipes; no random drop is required to complete the collection.

Seven unique gear effects, tempering to Rare using seals plus banked Hollow Shards, four socket relics with trade-offs, and two specialization choices for each of five classes. Specializations unlock at Bladecraft 25; socket slots at the beacon, Bladecraft 75 and guardian five. Loadouts include these choices and preserve legacy saves. Unique effects appear in item details. Level remains capped at 100; new progression is equipment, build options, collection and expedition depth.

Refuge → Beyond the beacon opens expedition discovery, relic targets/forge, route choices, Depths, carry-over choice contracts, weekly guardian hunts and assistance. Hero opens specialization/sockets. A tracked relic shows the next requirement and appears in the return report. Production mastery adds one ordinary material/food output every tenth completion from 250 mastery, every fifth from 1,000; blueprint components/equipment are excluded. Existing speed mastery remains bounded.

Hollow Depths unlocks after guardian three. One room per decision; bank or continue. HP/attack/armor/pressure increase with depth, with a second higher-risk choice. Defeat loses unbanked shards only. The implementation bounds stored depths at 1,000; this is not a claim that 1,000 floors are beatable. Choice contracts carry over, a completed board renews on a later UTC day, and weekly targets rotate among previously cleared guardians. There is no streak penalty or expiring accepted contract. Weekly variation is a target change, not new weekly combat mechanics.

## Rewarded assistance boundary

Only the native earned-reward callback unlocks four hours of simulated play/offline assistance. Requesting, dismissing early or failing an ad grants nothing. The player must enable assistance and choose a target/repeat hunt. Existing manual queues and explicit material plans remain free. Assistance uses existing time/resources, prepares at least 30 meals or the forecast reserve for a demanding hunt, works toward the tracked relic and then repeats a chosen hunt. It re-evaluates one cycle at a time, requires manual first clears for optional guardians, excludes Depths, stops for unsafe forecasts/defeat, and finishes the current cycle on expiry. Rewatching refreshes remaining time to at least four hours; it does not stack unlimited time.

Android uses the existing official test IDs. Production ads remain blocked. Mock callbacks verify local grant logic, duplicates and stale journeys; they do **not** verify native serving, consent or rewarded-ad completion on a device. No live ads, billing or paid service were activated.

## Difficulty method and findings

Final bounded audit: 195 baseline encounter simulations, 180 counter-build candidates across guardians 3/5/7, then 30 extra seed checks on the selected counters. Baseline seed 42; counter verification seeds 7 and 2026. Source: tests/balance34.gd and tests/counters34.gd. Raw baseline and selected-counter results: balance34.json and counters34.json beside this report. Rejected counter candidates are not retained individually.

All optional-guardian fixtures use level 100, high existing talents/relics/runes and plentiful top-tier food at a 90% healing threshold, with no potions. These measure combat feasibility, not the time required to earn a build or farm its food. “Under” means under-tier equipment, not an otherwise fresh character. Enemy prerequisites are seeded; exact fixture definitions remain in the scripts.

| Fixed build / five classes | Guardian 1 wins | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dusksteel Common, existing capped support systems | 5 | 4 | 1 | 0 | 0 | 0 | 0 |
| Dawnsteel Rare, same support | 5 | 5 | 3 | 1 | 0 | 0 | 0 |
| Dawnsteel Legendary, path + offensive sockets | 5 | 5 | 5 | 3 | 1 | 1 | 0 |
| Unique armor at Rare, Legendary weapon, offensive sockets | 5 | 5 | 5 | 5 | 5 | 4 | 2 |

The same fixed build becomes less reliable deeper into the guardian chain. Counter builds use only equipment available from *earlier* guardians, avoiding a circular unlock requirement. All five classes beat guardians 3/5/7 with their selected counters in all three seeds: 45/45 selected-counter encounters. Guardian seven counters use the sheltered route (12% less incoming damage, 20% less gold/XP); other sampled counters use standard risk. This is a meaningful preparation choice, not evidence that all builds can win.

| Guardian seven counter | Time across 3 seeds | Meals | Highest received hit | Lowest HP before food |
|---|---:|---:|---:|---:|
| Warden | 418–428 s | 129–134 | 61 | 39 |
| Ranger | 240–256 s | 75–81 | 73 | 27 |
| Arcanist | 256–272 s | 80–86 | 80–86 | 14–20 |
| Reaver | 192–208 s | 60–65 | 91 | 9 |
| Apothecary | 480–488 s | 148–153 | 90 | 10 |

The damage-oriented Reaver is fast but has very little margin; slower defensive classes consume more food. Initial prototype values made later bosses unreachable for multiple classes. HP/attack/armor/pressure were tuned to establish viable counters without making the fixed Legendary build sufficient. Third-strike pressure survives armor stacking, phase two raises damage, and long fights ramp damage by 12% every 15 enemy attacks up to +150%. Damage resistance and some guardians' recovery keep pure armor/food stockpiles from solving every fight.

With the fixed unique-armor build, all five classes clear Depths 1 and 5; two clear 10; none clear 20 or 50. For Warden, room time rises from 124 s at depth 1 to 416 s at depth 10 before failure at 20. This demonstrates increasing pressure against unchanged strong builds. It does not establish each class's absolute maximum depth.

Six campaign checkpoints across five classes also ran: Ash Rat (4–6 s), Bellkeeper (26–44 s), regional Wilds tier five (24–36 s), first Wilds Apex (46–72 s), middle Marsh Apex (96–216 s), final Crown Apex (148–262 s). Fixtures use the stage's level/material/quality with no talents, relic or rune damage bonuses. All 30 prepared examples won. Early enemies are intentionally farmable once prepared. Campaign values were not globally nerfed or inflated; deeper optional progression supplies the new difficulty ceiling.

## Verification and corrections

- 83 existing essential checks pass. Expectations updated only for the expanded catalog, earned mastery output and the intentional blueprint/manual-drop requirements.
- 38 focused checks pass: discovery/blueprints, guaranteed purchase, two-stage crafting, socket ownership, loadout restoration/JSON save, temper references, Depths escrow/banking/defeat, daily carry-over/rotation, weekly reward once, mastery thresholds, assistance chunk/save equivalence/expiry and mock rewarded callbacks.
- Existing five-class creation/name/point/save/offline/discovery checks pass.
- Phone UI capture script passes eight feature pages, four 360×800 layouts at 130% text, actual route and target button input, and a live guardian battle. Thirteen captures. Visually reviewed expedition art/copy, specialization controls, Depths risk forecast, assistance and combat.
- Corrected JSON number handling for the optional `-1` specialization. Corrected fractional catalog IDs in loot paths, temper stack capacity, misleading Depths/route reward text, scaled Depths battle health, duplicate contract selection after board renewal, and selling the last equipped socket relic.
- Existing save schema remains version 1 with optional validated fields. No user save was modified by audit/preview fixtures.

## Limits

This is a bounded simulation audit, not an exhaustive proof of balance, a full fresh-save playthrough, or measured retention. Supply acquisition time, every mixed build, all prior guardian trials, multi-day economy, physical Android lifecycle/performance and real ads still need player/device sessions. Forecasts are conservative analytical estimates; near-threshold builds can differ from exact outcomes. Three seeds are not a statistical win-rate estimate.

UI shutdown still reports 11 ObjectDB instances/five resources in use, matching the previous version. The isolated mock-ad test reports 21/seven at shutdown, with functional checks passing; cleanup remains unresolved. Art is generated painted imagery, not skeletal animation. No production-readiness or AAA/SSS completion claim.

## Android artifact

Android Gradle debug export exited 0. `build/android/ashen-covenant-0.34.apk`: 222,451,560 bytes; package `com.ashencovenant.prototype`; versionCode 34 / versionName 0.34.0; arm64-v8a and x86_64 confirmed with aapt. SHA-256: `9F395BB2CBB60EE536007933963A4CE8F2967B815D7629B7A293D17F8DCF07AE`. Final export includes corrected first-clear and Depths defeat copy.
