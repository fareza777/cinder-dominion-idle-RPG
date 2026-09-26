# Task-bar animation and hero equipment — 0.31

## Delivered behavior

The user's clarification controls the final layout: a small 64x54 animated thumbnail sits in the bottom activity bar beside the task name and progress. Large work scenes are not included on Refuge, Skills or the queue dialog. The thumbnail follows the active queue entry across pages. Mining, woodcutting, fishing, smithing, cooking and alchemy each use four original painted poses. Noncombat loops use simulation time with a maximum 2.4-second visual cycle; the visual never produces rewards. Combat uses existing hero poses and the actual enemy image, with a recent-hit cue. Waiting tasks use a still, subdued image with a pause mark. Empty queues hide the thumbnail. Reduced motion keeps a still pose; redraw is capped at 15/30 per second according to battery mode.

Queue detail counts and progress update live. A queue structure or blocked-state change rebuilds the detail only while its original dialog remains open, avoiding replacement of an unrelated dialog.

Hero now features original full-body art, six interactive slots connected to body locations, quality-colored borders, and dim example icons for empty slots. Slot selection lists owned equipment and routes into the existing comparison/equip flow. Empty slots offer available crafting plans and gear paths. Pickaxe, axe and fishing rod choices remain below the portrait. Stats, set bonuses, talents, supplies and existing loadout controls remain available. The portrait is explicitly labeled as the base appearance; equipping changes slots/stats, not the painted body.

## Assets

Built-in image_gen generated two 1024x1536 PNGs, copied unchanged into the project:

- `assets/art/hero-armory-0.31.png`: base hero and armory illustration.
- `assets/art/work-poses-0.31.png`: 24 frames, four columns and six activity rows. Runtime cropping uses observed unequal painted row edges and excludes separator pixels.

Exact prompts, source filenames, dimensions and crop metadata are recorded in `docs/activity-equipment-art-0.31.json`. No image CLI, paid service integration or external publication used.

## Actual verification

- `tests/capture31.gd` passes six activity-thumbnail selection/pose checks driven by advancing model time; reduced-motion still frame; queue handoff, empty and missing-material states; actual hero slot tap and equip tap; six populated slot icons; empty-slot crafting route; tool selection; combat thumbnail and combat equip lock; and save encode/decode.
- 16 final UI captures cover six work categories, queue, blocked work, empty slot, starter/equipped hero, item selection, combat, narrow hero, narrow footer and narrow queue. Reviewed task-bar placement, hero slots and text at 480x960 and 360x800 with 130% text. No full-screen work artwork remains.
- `tests/capture30.gd` rerun against the final thumbnail layout: all six onboarding tasks, shell rebuild, final Continue, restored navigation, saved dismissal and narrow Skip pass. Historical 0.30 screenshots are restored after this regression run.
- Final capture and onboarding error logs are empty. Godot debug export and package verification recorded below.
- During development, a capture assertion needed a second process frame before reading a persistent control, and the fixture used a display-name-derived `cuirass` ID instead of catalog ID `dawnsteel_chest`; both fixture issues were corrected. User-directed compact layout superseded early large-scene captures.

## Limits

Four painted frames per work type, not skeletal animation. Frames share skill archetypes across material tiers; this is not unique art for every recipe. Hero body artwork does not swap with equipped armor. The default battery-mode redraw cap is not a measured Android performance result. Physical Android touch, lifecycle, memory and battery remain untested. Checks were limited to affected UI flows, not the entire economy suite. Existing saves and progression rules are unchanged.

## Android artifact

Godot 4.7.1 final debug export completed after the compact-footer change. `aapt` verified package `com.ashencovenant.prototype`, version code 31 and version name 0.31.0. APK: `build/android/ashen-covenant-0.31.apk`, 93,377,817 bytes. SHA-256: `5DDC8D34B6032D9A29DE42BB4DC18E23C86EDD8732FE6DD0BD257BC8B774A72E`.
