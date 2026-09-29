# 0.51 — Battle figures, artisan equipment and dungeon journeys

## Delivered

- All 120 enemies have mapped transparent ready/attack figures (240 generated poses in ten atlases), body-size groups, anticipation, attack/recovery, recoil and dodge. Eight hero figures remain, with all eight skill effect paths exercised. Floating damage/healing/MISS use outlined text without dark rectangular plates. Larger creatures fit below the nameplate and inside the battle viewport. Reduced motion and battery draw settings remain available.
- Eleven new art atlases: ten enemy sheets plus 48 artisan/item icons. Two sheets received additional face-concealment edits. Prompts/original paths: `docs/art-provenance-0.51.json`. Figures use pose swaps and procedural movement, not skeletal/3D animation. Twelve guardian trophy icon archetypes are shared among 48 trophy definitions.
- 682 item definitions: 242 equipment, 310 materials, 120 cards, seven foods and three potions. 232 crafting recipes, 19 gathering activities and 120 hunts. Added 60 equipment and 24 materials/tools. Hero, enemy, story, contract and level counts are unchanged from 0.50.
- Smithing rolls Common through Legendary; Uncommon/Rare carry one trait, Epic up to two, Legendary up to three. Twelve slot-compatible traits include Burn, Poison, Chill, Bleed, Weaken, Armor Break, Barrier, Regeneration, attack/armor and tool speed/yield. Procs use the existing fourth-strike status system. Fixed-quality named recipes keep their promised output. Traits remain per equipment instance through save/refinement/tempering, without merging into plain stacks.
- Four reusable hammer tiers, four cooking knives and four alchemy mortars, selected from Skills. Blackstar Hammer plus Smithing Lv.90 permits exceptionally rare Legendary rolls; probabilities remain hidden in game. Guaranteed Legendary refinement additionally requires Smithing 90+, at least five million base coins and 20 final-route materials. Existing Legendary equipment is preserved.
- Axes, picks and fishing rods gain six paid upgrade ranks with increasing Smithing/material/coin requirements. Rank and quality shorten the remaining gathering cycle even at the base speed cap. Rank/Bountiful provide deterministic extra ordinary supplies; knife/mortar tiers increase repeated-batch yields. These bonuses do not increase rare card/material odds.
- Twelve guardian pools contain 48 Rare-or-better trophy equipment definitions. Secondary ordinary materials vary by region. Separate saved loot RNG preserves combat timing and online/offline equivalence.
- Twelve discoverable dungeon journeys, 1–8 hours, provisions/fees, build/level gates, steady/perilous preparations, four timed caches and a final vault. A travelling hero cannot simultaneously hunt/craft. Recall retains earned caches but forfeits the vault. Completion stores rolled rewards before a single claim. These are automatically resolved expeditions gated by preparedness, not manually explored dungeons or separately simulated boss battles.

## Actual verification

- 32 focused overhaul checks passed: counts/art mappings, references, old saves, rarity/hammer gates, unique gear, actual combat procs, refinement preservation, tool cycles/yield, malformed-state rejection, atomic charges/claims, recall, online/offline save parity, all twelve route completions, affixed crafting and endgame tool speed.
- 83 essential checks passed. The first run found secondary-loot seeding depended on the last saved simulation chunk. Seeding now uses the live RNG state; the full rerun passed. The subsequent secondary-material pool adjustment was followed by the expansion suite's combat/chunk equivalence check.
- 30 expansion regression checks passed: restricted cards/migration, attunements, regional rewards, loadouts, discovery gates, Depths and combined hero/rune/set offline combat.
- UI captures completed without script/runtime errors at 412×892 and 360×800 with 130% text. Inspected rat, hound, guardian, large leviathan, damage/MISS, artisan bench, tool upgrade, departure, live stage refresh and ready rewards. All eight hero skill render branches exercised. First giant capture exposed clipping; dimensions/anchor were bounded and the corrected capture inspected.
- Preview fixtures do not open player saves. Package/signing and save identity preserved; no paid-service activation.

## Limits

No physical Android playtest, exhaustive per-pose review at every screen size, full-campaign balance, statistical drop study, multi-day economy simulation or mobile memory/performance profile. Generated poses may still need individual refinement. Enemy atlases load on demand and are cached; mobile memory impact remains unmeasured. This is an expanded debug preview, not a completed SSS/AAA release.

## Android package

Version 0.51.0 / code 52, package `com.ashencovenant.prototype`, arm64-v8a and x86_64. APK `build/android/cinder-dominion-0.51.0.apk`: 297648973 bytes (~298 MB decimal). APK Signature Scheme v2 verified. SHA256: `E8AF29BF10DDC5AB4131FDA9F9E6914DD983FEC5993A5D3EC4BF7A0880906D7A`.

Final exporter reached `[DONE] export` and its child exited. The remaining identified console wrapper PID25520 was stopped after package verification; no natural export-exit-zero claim. Existing ignored build-copy/import warnings remain. Whitespace check passed.
