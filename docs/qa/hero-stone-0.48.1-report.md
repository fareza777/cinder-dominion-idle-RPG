# 0.48.1 — Stone behind hero equipment

User selected stone after the iron/stone comparison and requested an APK. The default hero-stage rail texture now uses the existing generated fortress floor; individual equipment slots keep iron. Other 0.48 visuals, gameplay and saves remain unchanged. VersionName 0.48.1, versionCode 49, existing Android package and signing setup retained.

Focused `tests/hero_stone_default.gd` asserts the actual default asset (no preview override), captures normal/130% text, and opens the weapon slot via real pointer in both layouts. Passed; screenshots under ignored build files. Existing exit warnings persist: 11 ObjectDB instances and five resources. No physical-device test or new art generation.

APK: `build/android/cinder-dominion-0.48.1.apk`, 249,084,199 bytes. Package `com.ashencovenant.prototype`, version 0.48.1/code 49, arm64-v8a/x86_64. APK Signature Scheme v2 verifies. SHA-256: `5C108628F81C899B3DB898113ED0679A8A3D52C888A11A9BAE8E551B3C23D7F9`.

Export reached `[DONE] export`; child exited. Known console wrapper lingered, was identified by PID/command line, and stopped. No natural export exit-code-zero claim.
