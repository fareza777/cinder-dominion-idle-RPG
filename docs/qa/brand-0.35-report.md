# 0.35 — Cinder Dominion: Idle RPG

Public-facing rebrand, transparent emblem and clearer hub terminology. The header character thumbnail becomes an iron-crown/ember emblem; splash and menu use the same identity with readable native text. User rejected the initial square matte, so a second built-in image-generation edit supplies real transparency. Final asset: assets/art/cinder-dominion-emblem-0.35.png. Exact prompts and retained sources: docs/brand-art-0.35.json.

Refuge navigation becomes Stronghold, Refuge Services becomes Town. Related help, contracts, upgrade descriptions and soundtrack labels are aligned. About/Share/Rate use the new name; sharing still requires the player's action. All in-game copy remains English. About includes the seven optional guardians and Hollow Depths. A broader page design recommendation is delivered separately in docs/premium-ui-direction-0.35.md; this iteration does not claim a full redesign of Hero, Bag, Explore or Skills.

## Save continuity

The project name remains Ashen Covenant internally because Godot uses it for the original Windows user:// storage directory. The running desktop window title uses ui/brand.gd; Android display name uses its package label. Android application ID remains com.ashencovenant.prototype. No save schema, resource ID, economy or combat rules changed. No real user saves were opened or rewritten by the capture fixture.

## Verification

- Godot editor import completed without script errors.
- Capture script passes splash, main menu, About, header/Stronghold, 360×800 large-text navigation bounds, saved-journey menu and the unchanged legacy user-data path. Six captures under docs/qa/screenshots/brand-*-0.35.png.
- Final main-menu screenshot visually inspected: emblem blends directly into environment art without a square matte; title/genre/primary action are readable. Narrow header/navigation and resumed menu also reviewed.
- Final generated PNG is RGBA, 1254×1254, with alpha ranging from 0 to 255. No image-processing script edited the generated pixels.
- Existing shutdown warning remains: 11 ObjectDB instances/five resources in use. Physical Android launcher masking, native launch presentation and device layout remain unverified. This cosmetic iteration did not rerun the combat balance suite.

## Artifact

Android debug export exited 0. APK: build/android/cinder-dominion-0.35.apk, 226,125,364 bytes. aapt confirms display label Cinder Dominion: Idle RPG, unchanged package com.ashencovenant.prototype, versionCode 35 / versionName 0.35.0, arm64-v8a and x86_64. SHA-256: 5A7CCC7C0AB8A8977610197539CD8211CF807DE39806D0DB941A138D5E50018A.
