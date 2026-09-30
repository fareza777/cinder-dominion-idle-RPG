# Banner above Android navigation — 0.55.1 / code58

User reported the0.55 banner obstructing Android navigation. Inspection of the vendored native Banner bytecode confirmed BOTTOM margins came from Godot's safe rectangle; the game separately reserved only banner height and14 logical pixels. Neither explicitly reserved hidden system navigation space for the native banner.

Added a project-owned Android bridge using WindowInsets, including stable navigation-bar dimensions when immersive mode hides the bars, gesture exclusion and display cutouts. The native banner receives8dp separation above system navigation. Parent screen coordinates prevent duplicate insets in already-fitted windows. Margins update before drawing and after layout/inset changes. Godot waits for native positioning and reserves matching space beneath game navigation. SDK binaries, ad units, pacing, rewards and saves unchanged.

Verification: native Java compilation passed; six inset geometry cases passed;35 focused service checks passed (the existing33 plus native clearance and double-inset reservation). A360×720 rendered phone preview checked Stronghold and130% Hero with simulated banner/navigation regions; real pointer Hero navigation remained usable. These images are explicitly layout previews, not screenshots of Android or Google ads. Initial capture fixture encoding/line-ending errors were fixed before the successful run. Existing focused harness shutdown warnings11 objects/five resources remain. No connected Android device: actual three-button/gesture/immersive behavior still requires device confirmation.

The first export revealed a required exporter name override; corrected before final export. Native source, reproducible build script and binary are tracked. No publishing, push or live ad integration.

## Package

Android debug0.55.1/code58, `com.ashencovenant.prototype`, arm64-v8a/x86_64. APK315,870,120 bytes; v2 signature verified. Manifest registration and DEX class/method presence for BannerSafe verified. Final exporter reached `[DONE] export` without the earlier required-method error; child exited, remaining identified console wrapper stopped afterward.

SHA256: `6863622EB7ADDB744E38DBEFDFBE8C98D86529736B96ECC03D9B3648F96BEB0E`.

APK: `build/android/cinder-dominion-0.55.1.apk`.
