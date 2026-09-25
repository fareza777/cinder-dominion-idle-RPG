# Foundation 0.1 — 25 September 2026

Implemented solo. Testing deliberately limited at the user's request.

## Evidence

- Godot 4.7.1 import and desktop startup completed without script errors.
- Nine compact assertions passed: catalog size, gathering, single ingredient debit, insufficient ingredient rejection without partial debit, combat advance equivalence (one 60-second batch vs sixty one-second batches), current Unix timestamp validation, save/RNG roundtrip, negative inventory rejection, duplicate command rejection.
- Actual rendered captures of village, exploration, combat, skills, inventory and character inspected. Variable fonts were pinned to readable static weights. Item atlas regions were adjusted to the painted row boundaries.
- Android debug APK exported and signature verified by the exporter. Includes ARM64 and x86_64. Installed successfully on Android 36 emulator and reached `OnGodotMainLoopStarted`; host GPU log contains no matching script/parse/fatal or Godot ERROR lines at startup.
- Initial SwiftShader emulator renderer failed shader linking. The same limitation is tracked upstream at https://github.com/godotengine/godot/issues/109550 . Host GPU rendering works; this does not establish support for SwiftShader or all physical GPUs.
- Emulator System UI briefly displayed its own not-responding dialog during startup; dismissed with Wait. This was not a game process exception. Emulator performance is not a battery or frame-rate benchmark.

## Scope of assurance

These are smoke and domain checks, not a full QA pass. No multi-hour balance playtest, store review, purchase flow, physical device matrix, exhaustive font/safe-area pass, or stress/fault-injection suite was run. Save backup/import is implemented but not comprehensively tested through Android's native file picker. Full English localization, cloud services, purchases, and later content milestones are unfinished.

The APK is an internal debug build for user playtest, not a public release candidate. Screenshots show the application, not a design mockup. The first territory and its boss are implemented; progression pacing and boss balance need user playtest.
