# Ashen Covenant development

Engine: Godot 4.7.1 stable, GDScript, Compatibility renderer. Internal portrait prototype.

Execution is solo as explicitly requested. User requested minimal testing and will playtest personally. Retain build/import checks and compact save/economy checks; replace exhaustive TDD, repeated suites, and independent agent review with this narrower policy.

Open project.godot in Godot, or run the engine with --path pointing at this directory. Exported builds are placed in build/ and not committed.

## Art direction from 0.33 onward

Keep every depicted face concealed: opaque hood/veil or fully closed featureless helmet, with no visible eyes, nose or mouth. Include enemies, background statues, ornaments, work frames and fallback assets in art reviews. Do not reintroduce prior complete-face images from historical commits or QA screenshots. Preserve dark fantasy identity through cloth, silhouette, weapons and lighting. See docs/faceless-art-0.33.json for the reviewed asset inventory and prompts.

## Public identity from 0.35

Public title: Cinder Dominion: Idle RPG. Keep project.godot application/config/name as Ashen Covenant: it is the legacy desktop user:// directory key. ui/brand.gd and the Android package label provide the visible title. Keep com.ashencovenant.prototype and signing identity stable for upgrades. Brand art must be a transparent emblem on UI, without a rectangular matte or a portrait substitute. Stronghold is the village tab; Town groups its services. Internal village/refuge IDs remain stable.

## Main-page design from 0.36

Use RealmUI.scenic for art-led headers with text in container flow, RealmUI.section for quiet dividers, primary bronze buttons for immediate actions and secondary etched controls for tools. Keep the persistent Goals coach target. Inventory supply actions now live in pages.supply_details; hunt controls live in hunt_preparation and hunt_routes. Preserve source/potion/sale access when changing these views. New environment prompt and source: docs/page-art-0.36.json. UI screenshot bounds must compare logical Godot coordinates, not physical raster dimensions under canvas stretch.
