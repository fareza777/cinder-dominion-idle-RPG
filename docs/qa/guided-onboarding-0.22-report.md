# Build 0.22 verification

## Completed checks
- Existing 77 essential checks passed; no economy modifications.
- Isolated capture22 preview walked all six real beginner objectives using actual button signals, confirmed task quantities through gameplay, equipped the Copper Sword and defeated three Ash Rats. First Supplies completed.
- Guidance enable/skip/restart and save encode/decode round-trip checked without touching the user's campaign.
- Nine screenshots captured and reviewed at 480x960 and 360x800 with 130% text. Focus outline, pointer, instruction card and actual Begin/Equip controls remained separate and readable. Active work focused the progress footer.
- Audio director smoke verified all four loaded tracks use forward looping, hearth switches to wilds, both voices mute via settings, and the active voice pauses.
- Initial audio assertions expected a setting change before the next process tick and expected an inactive stopped voice to report paused. Corrected the smoke to wait for processing and inspect the active playing voice. Final capture run completed with an empty error log.
- Final import had no script errors. git diff --check passed.
- Generated audio metrics: 32 kHz stereo, four tracks of 64 seconds; score peaks -9.90 to -8.40 dBFS, RMS -20.78 to -18.06 dBFS. No PCM clipping. Nine effect files generated with capped peaks. These numerical checks do not establish subjective listening quality.
- Android debug export signed and verified. Package com.ashencovenant.prototype; versionCode 22, versionName 0.22.0; arm64-v8a and x86_64.

APK: build/android/ashen-covenant-0.22.apk
Bytes: 85002063
SHA256: B6F1919E76B280894348E4314C88008E8C440646DA1B2B65A5B533FFEA45CEA5

## Remaining limits
No physical Android test, headphone/speaker listening review, interruption stress test or long-duration balance run. The score is synthesized original music, not recorded orchestral performance. Guided focus covers the six initial objectives; later progression uses normal Goals and Farm interfaces. Old saves remain valid; no existing save was overwritten by the preview. No paid services or publishing.
