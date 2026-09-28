# 0.46 — Ember title reveal and clean item art

## Changes

The original basic-item and ascension-item atlases contained painted backgrounds with partial alpha. Cropping those sheets into icons exposed rectangular patches. They have been replaced by transparent generated objects: 40 basic materials, food, potions, equipment and tools, plus 16 advanced swords, shields, ores and ingots. A separate four-object pass replaces raw meat, Worn Sword, Dusksteel Sword and Dawnsteel Sword after contact-sheet review exposed fragments from neighboring objects. These four replace entries within the 56, rather than adding four new gameplay items.

Per-object atlas rectangles, transparent margins and linear filtering are applied through the shared item renderer. Item aliases also inherit the replacement basic art. Existing transparent rare-material/masterwork atlases, card portraits and vector accessories are retained. Every catalog item still resolves to a texture; this does not mean all 267 items received individually new paintings. Card portraits intentionally remain rectangular illustrations. Raster files were not edited by script: alpha and connected silhouettes were inspected read-only to choose runtime regions. Touching advanced shield regions were reviewed separately.

The emblem was regenerated with smoother metal planes, quieter bevels and less visual noise. It is shared by the splash, menu, header and Android icon settings. The engine's old fortress boot image now uses this emblem. The in-game splash is a dedicated scene with a warm procedural light pool, ember particles, a moving highlight across the emblem, subtle scale/reveal and centered typography. It advances after 2.8 seconds or by Continue; reduced motion shows the settled composition and advances after one second. It does not pretend to show loading progress. A stale timer cannot dismiss a later splash instance.

No new facial art, character change, gameplay/economy adjustment or save migration. The opening is a short animated title reveal, not a prerendered cinematic movie.

## Assets and provenance

- `assets/art/items-0.46.png`
- `assets/art/ascension-items-0.46.png`
- `assets/art/item-details-0.46.png`
- `assets/art/cinder-dominion-emblem-0.46.png`

Generated with builtin image_gen. Exact prompts and original source filenames are recorded in `docs/item-splash-art-0.46.json`; runtime bounds in `data/item-art-regions-0.46.json`. Original assets/sources remain preserved.

## Verification

`tests/art46.gd` passed: all 267 item textures exist; animated reveal reaches its visible state; Continue opens the menu; normal and reduced-motion timers both advance. No parser/shader/assertion errors in the completed run. Four final screenshots were reviewed: splash, inventory and weapon recipe at 360×720 with 130% text, plus a 1000×1300 in-engine contact sheet of all 56 replaced concepts. A mid-word title wrap, a clipped review sheet, several neighboring fragments and inconsistent detail-icon scale were found and corrected during iteration. Final captures are in `docs/qa/screenshots/*-0.46.png`.

`git diff --check` passed. Combat tests were not repeated for this art/UI-only change. Physical Android cold boot, touch/performance and OS-specific adaptive-icon rendering remain unverified. Historical shutdown resource warnings remain unresolved; duplicate UID warnings during import/export concern the ignored build/admob source copy. This iteration improves specific visual issues, not a declaration of finished SSS quality.

## Android artifact

Export reported `[DONE] export`. `build/android/cinder-dominion-0.46.apk`: 242,565,335 bytes. Package/version confirmed: com.ashencovenant.prototype, versionCode 46/versionName 0.46.0, Cinder Dominion: Idle RPG, arm64-v8a/x86_64. APK v2 signature verification passed.

SHA256: `AFAC11F143ECFE2FEB525AF4415272B8762AAD72822E7A3A3BB77E0F4C05B5A4`.

The export child exited; its known console wrapper remained. Verified wrapper PID 9420 was stopped after artifact verification. No normal wrapper exit code is claimed. Physical Android testing remains outstanding.
