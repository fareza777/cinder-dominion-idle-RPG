# 0.38 — Accessory equipment foundation

First implementation stage of the approved hunting/progression design. Adds necklace, belt, left ring and right ring positions, nine craftable accessories and three original vector item icons. Steel, Moonsteel and Dawnsteel recipes unlock at Smithing 30/60/90. Accessories provide modest attack/armor and can be refined through the existing workshop. They do not contribute to armor set counts.

Rings use an item family separate from their left/right equipment position. Each newly created ring owns a distinct UID; identical rings do not stack. Moving one to the other hand removes its previous placement. Preview, equip-best, saved presets, loadouts and refinement share that ownership model. Save validation rejects one UID being assigned twice, including saved builds. Old saves need no destructive rewrite: absent accessory positions remain empty. Existing save version, project name and Android package are retained.

Hero presentation has ten labeled slots around the concealed-face portrait. Bag filters include accessories. Ring inspection selects the hand and previews the whole build, including removal from another hand. A taller hero panel scrolls on smaller phones; all slots are not promised above the fold.

## Verification

- 83 existing essential checks passed after initial integration (build/essential38.log).
- Focused accessories38.gd passed after adding refinement: distinct ring ownership, movement, preview purity and accuracy, invalid slot rejection, equip-best, legacy save decode, presets/loadouts, duplicate rejection, recipe completion and upgraded UID references (build/accessories38.log).
- Four rendered phone captures: hero and ring detail at 480×960; hero and ring selection at actual 360×720 with text scale 1.3. Slot non-overlap and horizontal bounds asserted. Images visually reviewed; no physical Android playtest.
- Existing UI shutdown warning persists: 11 ObjectDB instances and five resources in use. No new runtime assertion or parser failure in the focused run.

## Limits and remaining work

This stage does not implement stamina, cards, merchant rotation, long-term talents/relic ascensions or the unified status engine. See docs/progression-hunting-design-2026-09-28.md. No generated card art is included; accessory icons are SVG illustrations. Extra accessory stats have not undergone full endgame rebalance, and player trading remains out of scope: the confirmed market direction is offline NPC merchants.

Android debug APK: build/android/cinder-dominion-0.38.apk, 229588447 bytes. Godot reported [DONE] export; aapt confirms versionCode 38/versionName 0.38.0, com.ashencovenant.prototype, correct label, arm64-v8a/x86_64. apksigner verify succeeded (v2). SHA256: D83BB71FAEB2933F1526ACEDBB436105803CEDAB974687EA93B8584177E3A310. As in 0.37 the console wrapper remained after the exporter child finished; stopped only the identified wrapper PID 6524 after artifact verification. This is not recorded as a normal exporter exit code.
