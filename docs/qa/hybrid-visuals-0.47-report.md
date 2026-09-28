# 0.47 — Original ornament, clearer page structure

## Direction and changes

The user compared the initial redesign with 0.46 and preferred the older atmosphere. The accepted hybrid restores the original ornamental panel frames and dimensional secondary buttons. Compact horizontal currency, Equipment/Build/Legacy tabs, the shorter full-body equipment stage, direct-touch inventory and new environment art remain. Inventory uses three columns at normal text size and two at larger sizes; item frames retain rarity-colored edges and adequate inner padding.

Twelve generated locations cover forge, merchant, war room, relic altar, six professions (forge reused for smithing), and three late-game regions. No new character faces. Source and exact prompt are recorded in `docs/location-art-0.47.json`; the raster is unchanged and atlas gutters are inset at runtime. Stronghold service destinations open existing systems. Story frontier chapters and frontier battles now use location art rather than cropped boss art. The existing 0.46 animated splash is retained, not replaced or claimed as a new cinematic.

Battle composition is taller, with larger hero poses and static enemy art, preserved combat/status effects, and no space reserved for empty status lines. Preparation/secondary utilities follow combat. Merchant prices use the existing denomination formatter instead of calling every unit gold. Queue rows gain task thumbnails; cancellation help is collapsible. Settings has Display, Audio, Save and About categories, with test ads under developer options. Talent categories group existing talents without changing their unlock rules; route lines are visual grouping, not new prerequisites. Relics show one selected detail at a time. Frontier maps expose discovered encounter nodes and keep the existing reward and hunt gates.

Page scroll position is remembered per page/context. Card and masterwork detail returns remember their collection page. No save schema, drop probabilities, progression, economy rules, paid-service activation or publication changed.

## Verification

- Godot import completed without script parse errors after implementation corrections.
- `tests/hybrid47.gd`: 21 captured phone views at 360×720; five main pages, menu, battle, hunt preparation, queue, merchant, talents, relics, story, frontier and settings. Six additional captures use 130% text. Same nonpersistent max-level Warden fixture, not a player's actual save. Its initial story objective is synthetic and should not be interpreted as normal campaign progression.
- Real pointer input opened an inventory item. Hero tabs, inventory filter disclosure, scroll restoration, talent category/node selection, frontier node selection and all four settings categories passed. Large-text main pages did not exceed their scroll-container width.
- `tests/onboarding47.gd` reuses the existing real-pointer six-step walkthrough: gather, craft, equip, hunt; background remains visible, completion dismisses correctly, navigation resumes, saved dismissal survives, and narrow-layout Skip works. Outputs stay under ignored build files.
- Reviewed captured layout/art; recaptured after restoring ornamental frames, increasing tile padding and waiting for menu fade-in to settle. Existing shutdown warnings remain: 11 ObjectDB instances and five resources at exit.

## Limits

Desktop Godot phone-size rendering only; physical Android touch/performance and a long campaign playthrough were not performed. Large text may require vertical scrolling. This is a visual/navigation iteration, not a claim of completed AAA quality or implementation of every idea from the earlier audit. Source and test changes are committed; APK build output is ignored by Git.

## Android artifact

- File: `build/android/cinder-dominion-0.47.apk`, 244,877,377 bytes.
- Package `com.ashencovenant.prototype`, versionCode 47, versionName 0.47.0; arm64-v8a and x86_64.
- `apksigner verify`: passes APK Signature Scheme v2, existing Godot debug certificate.
- SHA-256: `4B3C7CD3694EFD36F203F4070495DA3DAE99B9476F2312AC9665660AED1E4582`.
- Initial export referenced an incorrect renamed launcher-icon path; corrected to the retained 0.46 emblem and rebuilt. Final export reached `[DONE] export`; child exited, lingering console wrapper was identified and stopped. This is not reported as a natural exporter exit code 0.
- Export scan warned about the ignored comparison project and duplicate AdMob helper asset UIDs under build; no export error was reported. Build/docs/tests are excluded from the APK export preset.
