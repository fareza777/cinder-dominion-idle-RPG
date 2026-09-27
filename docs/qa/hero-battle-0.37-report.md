# 0.37 — Five animated hero sprites, static enemy artwork

## Delivered behavior

The final direction follows the user's clarification: a small full-body hero sprite changes poses like the original battle animation, while enemies retain their own static artwork. This is not a sliding portrait or an articulated cutout puppet. The earlier Warden/Ash Rat puppet experiment was rejected and archived outside the runtime.

- Twenty generated poses: ready, anticipation, attack, recovery for Warden, Ranger, Arcanist, Reaver and Apothecary. All faces concealed. The same class-specific sprites appear in the small queue thumbnail; the old hero remains the legacy unselected-character fallback.
- Runtime UV polygons preserve painted blade tips outside nominal atlas cells without including neighboring figures. No raster post-processing. Source and prompts: `docs/hero-combat-art-0.37.json`.
- Enemy artwork no longer translates, rotates, scales, changes pose or receives a hit tint. Damage numbers, boss warnings and effects remain overlays; those do not animate the underlying art.
- Restrained class effects: Warden deflection glint, Ranger precision-cut trails, Arcanist curved ember wake, Reaver heavy slash, Apothecary rising healing wisps. No shield emblem, crosshair, magic-circle icon, cross-shaped health symbol or crossed-sword symbol. Existing large recovery/cast rings changed to light fragments and wisps.
- Ephemeral combat events identify actual successful skill triggers. Class effects respect skill rank, fourth strikes, third incoming hits, boss-only Reaver bonus and Apothecary food healing. No damage calculation, economy, save schema, native ads or purchase behavior changed.
- Reduced motion keeps sprites still and suppresses the new moving FX. The six-effect cap and existing 30/60 FPS setting remain. Existing music/SFX retained; no new audio was generated.

## Verification

- Godot import/parse and Android export.
- `tests/icon_battle37.gd`: all five classes have separate idle/attack frames; rendered hero pixels change while sampled enemy art pixels remain identical with effect overlays disabled; reduced motion keeps the hero image unchanged. Six final phone captures include a smaller window at 130% text. As in 0.36, the requested 360x800 desktop window saves a 360x720 viewport under the project stretch configuration.
- Four-second, 20 FPS recording of actual Warden model progression, rendered from 80 frames: `build/android/hero-battle-0.37-preview.mp4`. Silent visual recording; gameplay audio remains in the APK.
- `tests/battle_fx37.gd`: successful real combat triggers for five rank-1 classes, no class effects at rank 0, Reaver excluded against non-boss targets, misses and unrelated heals excluded, FX sampling leaves state/RNG unchanged. Durable enemy values used only inside this isolated test fixture.
- Essential checks passed. UI captures use isolated PreviewApp state; no player save writes. Skill-effect stills deliberately stage effects for visual review; the independent combat test verifies real triggers.

## Limits

Four discrete poses per hero, not continuous skeletal animation. Painted weapons do not change with equipped items. Physical Android performance, touch feel and native audio playback were not tested. Existing shutdown warnings remain (11 ObjectDB instances and five resources). No claim of finished AAA/SSS quality. The new sprite art is a visual iteration for user review.

## Build

Android debug version 0.37.0 / code 37, `build/android/cinder-dominion-0.37.apk`. Existing package and desktop save-directory key retained. Final export metadata recorded below.

Export reports completion. Android badging confirms package com.ashencovenant.prototype, version 37 / 0.37.0, label Cinder Dominion: Idle RPG, arm64-v8a and x86_64. APK size: 229568465 bytes. SHA-256: 4312546C787262E37E48445B541616F37AB52BE6B0EFD2A0DCB8D10DCB869673.
APK signature verification passed with apksigner. The Godot console wrapper remained alive after reporting export completion; it was stopped after package and signature verification. This was wrapper cleanup, not an observed APK validation failure.
