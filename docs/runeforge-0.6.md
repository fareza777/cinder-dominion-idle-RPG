# Ashen Covenant 0.6 — Runeforge and field records

The intent is a clear, rewarding idle loop with meaningful build decisions, English writing, original dark fantasy art and limited automated checks. Implemented solo under the user's continuing authorization. Brainstorming informed the scope; the user's explicit instruction to proceed independently takes precedence over repeated design approval gates.

## Player journey

The opening remains unchanged. After restoring the beacon, the refuge and Hero screen lead to the Runeforge. Defeating any tier of a regional guardian discovers that region's inscription. Players collect fragments, scraps and gold, review costs and effects, inscribe a rune, then explicitly equip it. One rune works alongside the existing fighting style and relic. Switching and removing it is free outside combat; forging is also blocked during combat.

The field journal groups victories across each region's five tiers. Existing kills and future offline wins count. At 5, 20 and 50 victories, a record grants one-time supplies. The primary action collects an available record before proposing more hunting. Tactics are available in an expandable section, keeping the next reward visible. Once records are complete, hunts remain available without timers or lost streaks.

## Runes

| Rune | Discovery | Rank I / II / III | Tradeoff |
| --- | --- | --- | --- |
| Thornscript | Any Ashen Wilds guardian victory | Fourth attack ignores 25% / 50% / 75% armor | Only affects every fourth attack; little benefit against weak armor. |
| Stillwater | Any Drowned Sanctum guardian victory | Enemy healing reduced 25% / 50% / 75% | No benefit against enemies that do not heal. Does not heal the player. |
| Dirge | Any Obsidian Crown guardian victory | Fourth attack deals 20% / 35% / 50% more damage after the style bonus | Every incoming hit deals 10% more damage, rounded up. |

Player attacks retain the same accuracy roll. Armor and outgoing damage use integer rounding; criticals apply afterwards. Warden still heals on a successful fourth attack. The shared combat rules are used by both live combat and the farming forecast. Forecasts remain estimates, particularly for potion timing, unlucky misses and long queues.

Each rank costs regional fragments / metal scraps / gold: 20 / 3 / 50, then 60 / 8 / 150, then 140 / 16 / 350. These fragments are shared with relic upgrades. There is no paid currency and no automatic equipping. The comparison panel uses a copy of the current build to show fourth-strike damage, incoming guardian special damage and relevant enemy recovery; it spends nothing and does not mutate the live build. It previews the next inscription rank, or rank III when fully upgraded, against that region's first tier.

Field rewards at 5 / 20 / 50 wins are respectively 10 / 25 / 60 regional fragments, 2 / 5 / 10 scraps, and 40 / 120 / 300 gold. Nine records and nine rune ranks are available in total. Records cannot pay twice.

## Presentation and integration

- Three original generated runestone artifacts, with provenance in `assets/manifest.json`.
- Fixed primary actions, visible reasons for blocked inscriptions, explicit equip confirmation and restrained English copy.
- Preparation describes the active rune; fourth-strike combat feedback distinguishes PIERCE and DIRGE.
- Refuge recommendations and offline summaries point to ready field supplies. The progression roadmap includes the rune loop.
- Optional validated `runeforge` save section; legacy saves without it remain readable. No schema-version increase or campaign reset.

## Production status

This adds strategic progression to the playable preview. It does not establish AAA production quality or measured retention. The game still uses illustrated actors rather than full character animation; campaign breadth, sound direction, long-term tuning, physical-device performance and release services need further work. Billing and advertisements remain disabled. No public release was performed.
