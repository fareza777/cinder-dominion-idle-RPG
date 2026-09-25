# Gameplay 0.3 — clearer decisions, deeper progression

Requested and implemented solo. Scope: make the existing Chapter I loop easier to execute and more rewarding, without claiming the full campaign is complete.

The supply planner recursively resolves deterministic production sources against a virtual copy of current inventory. It checks skill unlocks, displays costs and time, and rebuilds the plan on acceptance so a stale preview cannot overspend. It starts only with an empty queue; all existing reservation, cancellation and offline rules remain in effect. Chance drops and merchant purchases require a manual step. Equipment requires equipping after production.

Three freely switchable out-of-combat styles change attack and armor. Every fourth attack attempts a signature effect: Vanguard double damage, Warden 8 HP restoration, Reaver 2.5× damage. Warden trades 15% attack for 4 armor; Reaver gains 25% attack and loses 3 armor (floor zero). Misses consume the skill attempt. The attack counter is saved and shares online/offline event timing.

Eight one-time contracts track lifetime progress automatically. Food production uses cooking mastery rather than inventory gains so reward food cannot complete that objective. Claimed IDs persist and reject duplicate claims. Nine refuge ranks consume gold and scraps: Forge reduces cycle duration by 5% per rank (aggregate speed reduction capped at 45%), Gateward adds armor, Hearth adds 1 HP/second recovery per rank outside combat.

All new save state is optional on legacy schema-v1 saves, initialized lazily, and validated on future loads. No external network or monetization integration was introduced.

Presentation adds battle scenery using the original cinematic artwork, attack clocks, signature-skill charge, damage feedback, boss telegraph and latest victory/defeat summary. Reduced motion disables floating/shaking feedback but keeps readable static feedback. Idle Explore keeps the encounter choices closer to the top. Risk ratings describe a rough single-fight estimate and explicitly exclude skill/critical effects.

Limits: seven enemies and one chapter remain; no new regions, ranged/magic, pet system, billing or online services. Balance and device coverage remain for user playtesting.
