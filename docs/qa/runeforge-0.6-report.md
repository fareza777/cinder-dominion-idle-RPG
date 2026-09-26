# Runeforge 0.6 — focused verification

32 essential assertions passed. Six additions cover atomic inscription costs, idempotent forging and explicit equip, previous-kill credit and duplicate reward prevention, save round-trip/invalid ranks, all three mechanical rune effects, and offline consistency with rune changes blocked in combat. The legacy test removes the new optional save section.

The targeted UI capture exercised the real inscription and equip buttons and checked exact gold cost, rune rank and equipped state. It also activated the pinned field-reward action and verified that the completed Sanctum record was claimed. Six 480×960 screens were rendered: locked Runeforge, first inscription, equipped rune, field journal, rune-aware combat preparation and a 130% text Runeforge.

Visual inspection led to placing field rewards before expandable tactics, preserving a blocked-action explanation next to its button, prioritizing material costs over the detailed comparison, and making Equip the primary action after a newly forged rune. Game text remains English.

The initial test edit had a duplicate local variable name; it was corrected before the successful suite. UI capture completed without script errors. No prolonged balance run, retention experiment or physical Android device matrix was performed. Estimated farming results are not guaranteed outcomes.

Screenshots: `docs/qa/screenshots/*-0.6.png`.

Android debug export completed successfully, including APK verification. Version code 6 / version name 0.6.0. Package: `build/android/ashen-covenant-0.6.apk`, 74,582,505 bytes. SHA-256: `01F1D54432D3BE42EE90C44BA24737DAF2D86CB42F0711CDB5C51060FD29C20F`. Logs: `build/checks-0.6.log`, `build/capture-0.6.log`, `build/capture-0.6-errors.log` (empty), and `build/export-0.6.log`. This remains a debug-signed playtest build, not a Play Store release.
