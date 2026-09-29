# 0.51.1 — Complete battle figures and working journey entry

## Root causes and fixes

Enemy sprites were sliced into uniform 256×256 cells, although the painted figures do not follow exact row boundaries. Grave Thrall's head, for example, starts above the old row boundary. Transparent padding below each body also made apparent foot heights differ; fitting a rectangular portrait box could not repair either issue.

Measured all 240 enemy poses from their original alpha silhouettes. Two source figures that touch are separated with a curated ownership boundary. Stored exact bounds and UV clipping regions in data/battle_frame_bounds.json. Cached meshes preserve protruding heads/weapons while excluding neighboring sprite fragments, without modifying source PNGs or generating replacement art. Ready/attack poses share scale, retain aspect ratio and align their bottom edges. Hero foot padding is measured separately, preserving existing hero art. Ground position, motion margins and giant limits now stay inside the battle area; queue miniatures use the same enemy renderer.

The idle Dungeon Journeys button pointed directly to a method on a temporary RefCounted UI helper. Once the helper was released, Godot removed the signal connection. Reproduced with a real pointer: zero surviving pressed connections, no dialog. Changed journey entry/review/keep-travelling callbacks to closures that retain the helper. Locked journeys now open the Bellkeeper explanation; unlocked journeys open the route list normally.

## Verification

- Before/after pointer regression: callback invalid/no modal before the fix; valid callback/modal after. Full pointer path passed: locked entry, unlocked entry, Prepare, Depart, then Queue review. No direct call substitutes for the entry/depart button clicks.
- Rendered all 240 enemy poses using the actual renderer and inspected all ten gallery sheets. Found and corrected a source-overlap segmentation problem during this review; inspected the corrected sheet again. No uniform-grid head crops remain in these gallery images.
- Ready/attack battle captures for Grave Thrall, Thorn Colossus and Glass Leviathan at 412×892 and 360×800/130% text; checked complete heads, shared floor, large-actor margins and queue miniatures. Art remains differently proportioned by creature type; airborne/robed silhouettes keep their intended body shapes.
- No gameplay, rewards, save schema or progression changes. Preview fixtures do not touch player saves. Existing pointer-harness shutdown warnings remain (11 ObjectDB instances / five resources); no interaction/runtime script error in the completed flow. No physical Android playtest or new mobile performance profile.

## Package

Android debug 0.51.1 / code53, existing package `com.ashencovenant.prototype`, arm64-v8a/x86_64. APK: `build/android/cinder-dominion-0.51.1.apk`, 297685134 bytes. APK Signature Scheme v2 verified. Both measured-bounds JSON files confirmed present in the APK. SHA256: `EE8628905E7DB2331683326B4C37133284536CA734CD548778498B8E6C2668C2`.

Exporter reached `[DONE] export`, its child exited, and the identified remaining console wrapper PID516 was stopped. No natural export-exit-zero claim. Whitespace check passed. Existing application and save identity retained.
