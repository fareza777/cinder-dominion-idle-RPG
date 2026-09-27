# 0.36 — Main-page presentation

## Delivered

- Four original generated environment panels in one atlas: Cinderwatch, woodland outskirts, forge and treasury. Scenic headings put text in normal container flow over a dark gradient. No faces, figures or lettering in the new art. Exact prompt and source: `docs/page-art-0.36.json`.
- Stronghold leads with its town panorama, followed by the existing recommendation and Town services. Redundant outer service-button cards removed. The persistent Goals entry remains intact for onboarding.
- Explore shows a compact preparation summary, larger accurate enemy portraits, readable wrapping stats and a prominent Hunt action. Prepare for a hunt opens food/tactics/equipment controls. More hunts keeps gear progression, mastery and unlocked expeditions within reach without scrolling through every discovered enemy. Active combat retains its battle stage.
- Skills gets a forge header, larger resource icons and short descriptions of each skill's purpose. Existing recipes, training plans and level progression remain available.
- Inventory uses two-column equipment and supply grids. Inspect opens the existing equipment comparison. Details opens a new supply panel with live quantity, auto-use, source and sale actions. Existing filters, sorting, gear paging, salvage and overflow actions remain.
- Hero now leads with character artwork and equipment slots. Attributes and class skills follow the equipment section.
- Shared secondary buttons use restrained etched edges, primary actions retain bronze emphasis, neutral panels have less bronze tint, navigation uses a clear active top rule, shell bars have simple outlines, and dialog headings use the existing serif face.
- Menu and Settings inherit shared styling. Transparent emblem preserved. No combat balance, save schema, package identity or monetization changes.

## Verification

Godot 4.7.1 import succeeded. A bounded UI capture script covers all five main pages (top and bottom), recipe view, active battle, menu, Settings, equipment inspection, supply details and hunt preparation at a 480×960 window and a requested 360×800 window with 130% text for the smaller window. Actual saved viewport images are 480×960 and 360×720 under this desktop stretch/window configuration; this is not evidence of an exact 360×800 native Android viewport. Screenshots use the project's production canvas stretch; bounds checks use logical UI coordinates rather than physical screenshot pixels. The initial harness incorrectly compared those coordinate spaces; it was corrected and rerun.

Actual button signals verify equipment inspection, food selection, selling one item, opening tactics and reaching hunt mastery. The six-step onboarding regression uses actual pointer events and verifies guidance after shell rebuild, completion dismissal, restored navigation, saved inactive state and narrow-screen Skip. Saves are isolated by the existing PreviewApp fixture; no player save is written.

Rendered images reviewed for text overlap, readable art overlays, navigation, grid layout and action visibility. Evidence: `docs/qa/screenshots/premium-*-0.36.png` and `onboarding-*-0.36.png`. Historical capture files were not overwritten. No exhaustive model/balance suite was rerun for this presentation-only iteration.

## Limits

No physical Android device test, accessibility certification, native ad check or performance benchmark. This is a presentation iteration, not a claim of finished AAA/SSS quality. Deeper progression dialogs inherit the theme but have not all received bespoke compositions. Existing shutdown warnings remain: 11 ObjectDB instances and five resources in use. Hero armor art still does not change with equipped items. Native launcher masks remain unverified.

## Build

Version 0.36.0 / code 36, debug APK `build/android/cinder-dominion-0.36.apk`. Package and legacy desktop save-directory key retained. Final export exited 0. Android badging confirms `com.ashencovenant.prototype`, version 36 / 0.36.0, label Cinder Dominion: Idle RPG, arm64-v8a and x86_64. SHA-256: `9775F8B90ABA50FF8CF70DFE75B51915CB0E20EFA77E415E29831C6B8F766110`.
