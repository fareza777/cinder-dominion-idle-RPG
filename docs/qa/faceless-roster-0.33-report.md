# 0.33 — Concealed faces and five-character roster

## Delivered

The user's art direction requires concealed or incomplete faces. Reviewed all 19 original runtime PNGs and the icon/frame/control SVGs. Replaced complete faces in hero portraits, work animations, enemy portraits, combat poses, guardian/Apex atlases, the smith story panel and background statues. Fish item icons now use headless prepared portions; work animations use a closed catch basket. The legacy hero portrait was also regenerated and its work atlas replaced, so old saves do not retain the prior fallback art.

Fifteen generated outputs (14 edits, one new two-character portrait atlas) are installed locally. Thirteen original runtime PNGs are replaced and three new PNGs added. All five classes have four poses for each of six professions, 120 work frames total. Head coverings conceal eyes, nose and mouth; identity comes from clothing, silhouette and equipment. Reviewed all returned images visually before installation. This implements the requested visual criteria, not a religious ruling or certification.

Six existing scenery/object atlases remain: cinematic (back-turned hooded traveler), cinderwatch, world-map, ascension-places, ascension-items and runestones. None showed discernible complete faces during inspection. SVGs contain geometric decorations and the ember logo. Historical QA screenshots in docs retain prior visual evidence; they are excluded from APK export and are not used by the game. Exact prompts, sources, replacement paths and retained assets are listed in ../faceless-art-0.33.json. Built-in image_gen was used; no CLI fallback.

Two new free permanent-per-journey choices:

- Reaver: +20% attack, -40% armor. Sundering Blow adds 25/35/45/55% fourth-hit damage against bosses at class ranks 1–4.
- Apothecary: +1 armor, -15% attack. Field Remedy adds 6/9/12/15 HP to food healing in battle at ranks 1–4. It does not grant free food or change healing potions.

Ranks unlock at Bladecraft 5/25/50/75. Both use the existing attribute/save system. Forecast and runtime share their effects. Existing characters and legacy saves remain valid; no progress reset or paid access was introduced. Character choice uses two columns and places the name field first, with a fixed confirmation action.

## Verification

- Existing 83 essential checks passed.
- Character save/name/point/selection-lock and offline chunk-equivalence checks passed for all five registered classes.
- Focused new-class checks passed at levels 1/5/25/50/75, including boss-only Reaver damage and exact Apothecary healing increments.
- Actual pointer confirmation exercised all five selections. Portrait, 24-frame work atlas, skill and 360×800 / 130% text selector checks passed. Eighteen captures recorded. Reviewed equipment and narrow creation output.

## Remaining limits

Art is painted frame animation, not a skeletal model; changing equipped armor does not repaint clothing. Legacy work art shares the Warden atlas. New classes need long-session balance testing. No physical Android test, native keyboard or ad-serving verification was performed. Earlier AdMob production restrictions remain. UI shutdown still reports 11 leaked ObjectDB instances and five resources in use, as in 0.32; functional assertions passed, but cleanup remains unresolved. No claim of production readiness is made.

## Android artifact

build/android/ashen-covenant-0.33.apk: 220,202,388 bytes; package com.ashencovenant.prototype; versionCode 33 / versionName 0.33.0; arm64-v8a and x86_64. SHA-256: C42A5E15066C1DAE16E2E262D4E94BA106CC51D2367192019E87794AB34206A0. Export log reaches DONE without export errors; aapt confirms the package/version and both native architectures.
