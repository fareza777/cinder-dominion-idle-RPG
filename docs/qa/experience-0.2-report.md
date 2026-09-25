# Experience 0.2 — verification and delivery

Implemented solo on 25 September 2026. Verification kept deliberately small as requested.

## Delivered

English default, including one-time migration of pre-0.2 saves; branded splash; three illustrated cinematic scenes with optional motion, previous/continue/skip controls; New Game and Continue menu; four beginner cards; a persistent objective header and 12-step journey; contextual action counts, crafting costs, loot previews, food instructions, and accurate queue target labels. Advanced activity options are collapsed by default.

Settings includes About, licenses, Share, Rate, replay intro/tips, previous-journey restoration, backups, font/audio/motion options. New Game makes a verified archive before replacement. Merely opening the game creates no campaign. Menu time is caught up when continuing; intro reading on a new journey does not generate an empty offline popup.

## Checks performed

- Godot import and rendered screen captures. Menu, cinematic, onboarding, guide, recipe preview, Settings, and large-text guide were inspected.
- Thirteen compact domain assertions passed, including the previous nine economy/save checks plus English default, guided recipe sequence reaching Equip, tutorial progression toward Grave Thralls rather than a locked boss, and compatibility with saves that lack the new experience metadata.
- Android 36 emulator: installed APK; New Game opened the cinematic; skipped intro, opened onboarding and guide; began four mining cycles; observed four ore and the next objective, Smelt 2 copper ingots. Restart loaded the saved journey with Continue.
- Android native Share chooser opened with the intended message. No destination was selected and nothing was sent.
- Android checks found and fixed automatic Back-to-exit behavior and touch event blocking by buttons. UI checks found and fixed stale modal update callbacks and a detached-screen cleanup error.
- Final APK was installed using a streamed install. A finger swipe over Settings buttons now scrolls the panel. Back at the main menu opens the exit confirmation; Back again closes it while the game process remains active. Final app log contained no matching script, parse, fatal exception or Godot ERROR lines.
- Export creates a signed debug APK using Godot 4.7.1 and matching Android templates. Final build and verification evidence remain under ignored `build/`.

## Limits

This remains a Chapter I preview, not a public release. No physical-device matrix, extended balance pass, store review, billing or cloud tests. Cinematic presentation is illustrated scenes with fades/camera motion, not a rendered 3D movie or voiced cutscene. Indonesian remains selectable but new flows prioritize English; old saved chronicle entries retain their original language.

The emulator's System UI displayed an unrelated startup not-responding prompt, dismissed with Wait. Godot used the host GPU because SwiftShader has the limitation recorded in the earlier foundation report. Emulator observations do not establish performance on every phone.

Rate intentionally explains that no public store listing exists. `STORE_URL` remains empty until a real listing is available. Share currently shares a descriptive preview message, not a public download link. Native integration follows [Godot's Android API guide](https://docs.godotengine.org/en/4.7/tutorials/platform/android/javaclasswrapper_and_androidruntimeplugin.html).
