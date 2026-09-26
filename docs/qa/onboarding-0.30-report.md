# Clear onboarding and completion fix — 0.30

## Report and root cause

User requested visible, undimmed background with clearer guidance and reported the final Continue could not dismiss the overlay. A real-pointer six-step walkthrough passed without a shell rebuild, but reproducing `refresh_shell()` before completion caused the Continue tap to fail. Shell rebuilds preserve the coach and append new controls after it. Its z-index kept it visually on top while GUI hit testing reached later siblings underneath. Previous tests emitted the completion signal directly and did not cover this ordering problem.

The visible active coach now moves to the last sibling when necessary. Rendering and pointer input order agree after shell rebuilds and modal creation. The completion action still persists `coach_active=false`; no save migration or gameplay state reset is needed, including saves already at completion.

## Presentation

- No full-screen dim layer from the coach. Gold border and directional arrow remain.
- Welcome and dialogs opened during active guidance retain a transparent backdrop; panels remain opaque for text readability.
- Six English instructions specify action, quantity and purpose. Completion points to Goals and the gather/upgrade/hunt loop.
- Outside-target input remains blocked while actively guided, with Skip available. Finishing or skipping removes that block.

## Actual verification

- Before fix: `tests/capture30.gd` reproduced `REGRESSION: completion pointer tap did not dismiss onboarding` after a shell rebuild.
- After fix: six actual pointer-driven tasks, shell rebuild at start and completion, Continue dismissal, restored Bag navigation, inactive coach save round trip, and Skip/Continue at narrow large-text layout all passed. Final script also checks welcome backdrop alpha is zero.
- Six screenshots at 480x960 and 360x800 with 130% text; start, Begin and narrow completion/initial layouts visually reviewed. No overlapping guide text or clipped exit button in reviewed captures. Final capture error log empty.
- Checks were deliberately limited to the affected UI flow. No full gameplay suite rerun because economy/model rules are unchanged.

## Limitations

Pointer events were injected through the Godot viewport on Windows. Physical Android touch, system insets and lifecycle were not tested. Background controls remain visible but off-target controls are intentionally blocked until Skip/Continue; keyboard focus containment is not added in this patch. Broader audit work remains open.

## Android artifact

Godot 4.7.1 debug export completed. `aapt` verified package `com.ashencovenant.prototype`, version code 30 and version name 0.30.0. APK: `build/android/ashen-covenant-0.30.apk`, 89,547,180 bytes. SHA-256: `07B00CB557417CCD0DD36CF9659546E1C091CEFEE249FC8F72CCBF044DF2E49E`.
