# 0.39 — Late-game talents and relic ascension

Implements a bounded progression expansion from the approved hunting design. Existing three starter talents and ten early points retain their costs/effects. Six advanced ten-rank talents add special-strike damage, boss damage, boss mitigation, meal healing, third-strike mitigation and battle gold. The entire tree costs 75 points; only 60 can be earned. This preserves build choices rather than permitting all talents to be maximized.

Point formula: first ten from combined melee XP at 250 per point; additional floor((Bladecraft level − 20) × 50 / 80), floored at zero. Total is capped at 10 initially, then 20/30/40/50/60 after sequential victories over Bellkeeper, wilds_5, marsh_5, crown_5, secret_6. Thus XP alone cannot unlock all points. Advanced ranks 1–3, 4–6, 7–9 and 10 require Bladecraft 25/50/75/100 and Bellkeeper/wilds_5/crown_5/secret_6 respectively. Starter talents remain five ranks. Reset is free outside combat; loadouts retain allocations and recheck gates.

Relics extend to rank 40. Original base bonuses stop increasing after rank 10: +20 attack, +20 armor or +30 meal healing. Ranks 11–40 add, while equipped, 0.3% special-attack damage per rank for Ashfang, 0.3% reduced boss damage for Hollow Aegis, or one additional healing per five ranks for Emberheart. Maximum additions are 9%, 9% and 6 HP respectively. These use the shared combat/forecast rules. No direct quadrupling of armor or attack.

Ascension gates: upgrade from rank 10 requires Bladecraft 50 and the matching regional Tier 5 victory; from 20 requires Bladecraft 75 and matching Trial; from 30 requires Bladecraft 100 and the matching guardian (fang: Thorn Colossus, heart: Drowned Castellan, ward: Unlit Sovereign). Ranks above 30 consume one corresponding guardian core per upgrade. Existing fragments cost 5 × next_rank². Above rank 10 each upgrade also costs 2 + 2 × (current_rank − 10) essence, always matching the enemy's relic fragment identity. Regional Tier 3–5 bosses give one essence, Trials two, Apex/guardians/Depths three; early enemies give none. Rewards are deterministic and use the same offline simulation.

135 catalog items now include three essence materials. No destructive save migration is necessary: missing advanced talent keys read as rank zero, existing required starter fields remain required, and unknown talent keys are rejected. New ranks/allocations are checked against their unlock conditions. Existing project/package/save version remain unchanged. Old application versions are not promised forward compatibility with these new saves.

## Actual verification

- 83 essential checks passed after integrating progression and updating the deliberately changed rank cap/item count expectations: build/essential39.log.
- Focused legacy39.gd passed: weak-enemy XP cap, legacy keys, point cap, advanced rank limits, special-versus-ordinary damage, reset/loadout round trip, atomic rejection on missing materials, each relic ascension gate, final core consumption, maximum rank, save validation, source yields and real combat/time-chunk equivalence including essence gains. build/legacy39.log.
- Four phone captures: talents/relics at 480×960, relics/farming at actual 360×720 with text scale 1.3. Relic narrow view visually inspected. No physical phone test.
- Existing capture teardown warnings remain: 11 ObjectDB instances, five resources in use. No parser or assertion failures in the completed runs.

## Remaining scope

This is not the full future class tree/keystone or Paragon system. Unified status effects, monster cards, stamina and rotating NPC merchant are not implemented yet. The new six advanced talents are shared across the five classes; existing character specialties remain unchanged. Relics currently have fixed ascension identities rather than selectable traits. Full campaign pacing and all late-game builds have not been rebalanced; mitigation/damage gains are capped, but this is not proof of global balance. Cards still require their art and gameplay implementation.

Android debug export completed ([DONE] export): build/android/cinder-dominion-0.39.apk, 229596106 bytes. aapt confirms package com.ashencovenant.prototype, versionCode 39/versionName 0.39.0, label Cinder Dominion: Idle RPG and arm64-v8a/x86_64. apksigner verifies the v2 signature. SHA256: 8B78EFCA1F4AB9ACE32A67FC3F242BA2AA4BE393203A681069AD47E76E513AD1. The known console-wrapper hang recurred after export; only identified wrapper PID 18176 was stopped after APK verification. No normal wrapper exit code is claimed.
