# 0.45 — Recognizable currency

The upper-right wallet previously stacked tiny S/G/P abbreviations. It now shows a recognizable coin beside each denomination amount: a round wheat-engraved Silver coin, a warm crown Gold coin and an octagonal gem Platinum coin. These use the existing generated currency atlas with runtime cropping, not new generated art or raster processing.

Nonzero balances appear highest denomination first. Zero balance displays a Silver coin with 0. Each coin is a button opening Wallet, where the three matching icons have full English names and exact grouped balances. Very large header counts use truncated K notation; the wallet and tooltips retain the complete amount. Conversion rates and saved currency are unchanged. The menu button and game title remain centered as the number of coin rows grows.

## Verification

`tests/currency45.gd` passed with balances 0, 20, 1,234,567 and 123,456,789,012 Silver. Checked denomination decomposition, grouping, icon presence, visibility and the actual coin button opening Wallet. Five screenshots were rendered at 360×720 with 130% text; zero, early, mixed and large balances and the named wallet were reviewed. Final screenshots are under `docs/qa/screenshots/*-0.45.png`. Header icons were enlarged after the first review; the menu no longer stretches vertically alongside three currency rows. No text overlap observed in the reviewed states.

`git diff --check` passed. No economy or save migration was necessary. Known shutdown warnings remain (11 ObjectDB instances/five resources). Physical Android installation and touch testing have not been performed. This targeted UI change did not repeat the full combat suite.

## Android artifact

Export reported `[DONE] export`. APK `build/android/cinder-dominion-0.45.apk`: 240,571,345 bytes. Package/version verified: com.ashencovenant.prototype, 45 / 0.45.0, Cinder Dominion: Idle RPG, arm64-v8a and x86_64. APK v2 signature verification passed.

SHA256: `3A6220BE8F92E6111A83DEF991694CA104DF2528A8F94D8F609DCCDF64A6F717`.

The export child exited; the known console wrapper remained. Verified wrapper PID 21144 was stopped after APK verification. No normal wrapper exit code is claimed. Duplicate UID warnings concern ignored build/admob source copies.
