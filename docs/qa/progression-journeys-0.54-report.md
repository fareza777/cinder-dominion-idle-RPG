# 0.54 — Journey timing and purposeful progression

## Reported bug and evidence

The Journey countdown appeared frozen. Live Godot reproduction showed simulation time advancing by 2,200 ms while both formatted strings remained `1h 00m`. The formatter rounded remaining time up to whole minutes. This reproduced a display problem, not a stopped simulation clock.

The display now includes seconds, overall progress and the next chamber's countdown. Real pointer departure followed by a 2.2-second wait changed the visible label from `1h 00m 00s remaining` to `0h 59m 58s remaining`. Crossing chamber and completion boundaries refreshed the open dialog; the collect button appeared and actually claimed cargo. Offline elapsed time and repeated reopening were also checked.

## Implemented recommendations

1. **Objective → preparation → upgrade → farming.** Objectives continue through all 54 Far Marches encounters and all 70 Shattered Realm encounters. Optional trials, Apex hunts and guardians no longer interrupt that main road. Encounter preparation explains the counter, links weapon effects/cards, suggests stronger learned/unlocked recipes where available, opens the tracked ingredient planner, and links food/tactics before a single-fight trial. Completed tutorial milestones collapse during later objectives. Training messages name the actual profession.
2. **Encounter decisions.** Realm monsters use ten patterns aligned with creature type: opening rush, bleeding, restoration, guarded normal hits, reckless specials, healing curse, low-health execution, recovery/Slow, disrupted shell and phase-two Armor Break. These are ten patterns across seven regions, not seventy entirely different AI implementations. Combat and the bounded forecast share conditional damage rules.
3. **Card builds.** Seven Realm ruler cards now offer conditional pacts: Chill, burning specials, Poison setup, low-health offense, special-hit emphasis, third-strike defense and execution. Each has a downside. Slots, ownership, art and drop chances remain. No drop percentages or card rarity labels were added.
4. **Journey choices.** All twelve routes offer Supply passage, Sealed vaults or Elite patrol. The next chamber's choice can change while travelling and repeats offline. Supplies favor materials, vaults favor money/shards/equipment, and elite ambushes can forfeit one chamber's cache while preserving earlier cargo. These are staged resolutions, not separate simulated boss fights. Legacy journeys retain their original payout. Validation recomputes new cargo from completed chamber records.
5. **Equipment milestones.** Weapon attunements gain effects at equipment tiers 6, 11 and 16: a debuff, small Barrier and periodic removal of Wound/Weaken/Slow. Forge explains thresholds and links attunements. Other equipment retains existing rarity, traits, cards and sets; these new milestones are weapon-specific.
6. **Return activities/economy.** Frontline commissions select a known target from the three most valuable conquered hunts, rotate by day at acceptance, and pay currency plus ordinary drops. Bounties/contracts scale with proven encounter rewards. Weekly hunts include conquered Realm rulers and scaled currency/seals/shards. Unfinished boards carry over and claims remain one-time. Generic gathering/crafting contracts remain available.

## Verification

- 57 focused checks passed: twelve Journey routes, block/chunk offline equivalence, path changes, legacy/current saves, invalid reward rejection, recall/claim, closed-game completion, objective road, counters, seven card pacts, weapon milestones, commissions and rewards.
- 83 essential checks and 40 expansion checks passed. No full campaign replay.
- Existing six-step onboarding pointer walkthrough also passed: shell rebuild, completion, restored navigation, persisted dismissal and narrow-screen Skip.
- Real pointer flow covered Journey entry/preparation/departure, ticking seconds, chamber refresh, collection, build-panel card navigation, awakening disclosure and attunement navigation.
- Eleven phone captures reviewed: Journey preparation/running/rewards, build panel, awakenings, commissions, ruler card and late objective, including large-text Journey/build views. Requested windows were 412×892 and 360×800; actual captured surfaces measured **412×824 and 360×720** under desktop stretching. Large text uses 130% scale. Scrollable content and fixed actions stayed separated.
- Sixteen prepared Warden combat samples covered ten first-realm roles and six later rulers. All won; the final ruler took 1,044 seconds and 348 meals. These prove a viable prepared route, not balance for every class. Local results: `build/balance54.json`.
- Initial objective-test failures came from a fixture with only one early kill and missing tutorial gathering history; corrected to represent a completed early campaign. First UI run passed timer/completion assertions but called a nonexistent test-only font helper; replaced with the actual font-scale setting and rerun successfully.

## Limits

No physical Android play/performance test or full class/economy balance audit. Forecasts do not fully simulate effect uptime, conditional setups or cleansing. Elite Journey encounters use staged random outcomes. Existing UI harness shutdown warnings remain: 11 ObjectDB instances/five resources; the verified flow had no runtime script errors. No new art, paid integration, publication or finished AAA/SSS claim.

## Package

Android debug **0.54.0 / code56**, package `com.ashencovenant.prototype`, arm64-v8a/x86_64. APK: `build/android/cinder-dominion-0.54.0.apk`, **315,853,811 bytes**. APK Signature Scheme v2 verified; package name/version/architectures checked. The final archive contains 70 role-bearing enemies, seven card pacts and the new compiled build/Journey UI and combat rules.

SHA256: `19E6095E5AF982D86B7344E1769EAB45602C2A1714EFCF9A9BCF14B87FA5B9EC`.

The first export was superseded to include the final hidden-recipe recommendation guard. Final exporter reached `[DONE] export` and its child exited. The identified remaining console wrapper was then stopped after signature/archive verification; no natural export-process exit-zero claim.
