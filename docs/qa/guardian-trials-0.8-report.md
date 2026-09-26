# Guardian Trials 0.8 — limited verification

Date: 2026-09-26. Godot 4.7.1, Windows desktop renderer. Testing kept deliberately narrow at the user's request.

- 46 essential checks passed, including six added checks for tier-five gating, exactly-once Epic rewards and bonus accounting, offline/stepped equivalence, regional record credit, healing across the phase threshold, save round-trip and invalid phase rejection.
- Seven 480×960 UI captures cover locked, available, preparation, phase II combat, completed, hunt rewards and 130% text. The actual preparation and begin buttons launched the intended single trial.
- Reviewed screenshots for title wrapping, persistent footer, phase messaging and exact item/reward display. Fixed a narrow title layout before final export.
- The phase save check caught JSON number-type handling; validation now accepts valid integral JSON phases and rejects other values.
- Final capture error log empty. Android export completed and verified APK without script/export errors. No physical Android device installation or long-duration balance playtest in this iteration.

APK: `build/android/ashen-covenant-0.8.apk` (debug signed), 77,936,054 bytes.
SHA256: `D03A4F3422B536B5E1F1C12EEBC5EF08DA1519D2B15180EE794A04A298E139C9`

Screenshot evidence: `screenshots/trial-*-0.8.png`. Capture fixtures are isolated from player saves. Existing guardian art is reused; this is not a claim of new character animation or completed AAA production.
