# Adventure 0.4 — focused verification

Solo implementation and light verification, as requested. No emulator marathon, broad device matrix, full balance simulation or retention experiment was performed.

## Checks completed

- 22 domain assertions passed: previous 17 essentials plus talent/relic cost and stat effects, duplicate bounty protection and carry-forward behavior, completed-board rotation/save validation, first-clear expedition rewards/unlock ordering/offline consistency, and a long work order producing exactly 500 ingots and 4,000 Smithing XP from automatically gathered inputs.
- Legacy save check explicitly removes both new progression modules before decoding, preserving older schema-v1 compatibility.
- Godot 4.7.1 imported assets and scripts. Disabled commerce boundary and updated world UI passed syntax checks.
- Key screens rendered without script errors: fresh-game next step, returning hub, illustrated world map, talent paths, relics, bounty board, work orders, English Settings, expedition combat and 130% text hub.
- Visual inspection confirmed the primary opening action appears above the artwork; world map markers and tier buttons are readable; English Settings contains no language toggle; long orders show outputs and XP before acceptance.
- Final Android debug export and package verification are recorded in `build/export-0.4.log`. Physical Android installation is left to user playtesting this round.

## Limits

This is an expanded playable preview, not a completed AAA production. Expedition enemies reuse the original portrait cast as named/scaled variants. Retention and long-term balance are design hypotheses pending player feedback. Daily board timing is local-device based, not server authoritative. IAP/AdMob provider interfaces remain disabled; no live products, ads, transactions or entitlement delivery are implemented.

Screenshots: `first-step-0.4.png`, `returning-hub-0.4.png`, `world-map-0.4.png`, `talents-0.4.png`, `relics-0.4.png`, `bounties-0.4.png`, `work-orders-0.4.png`, `settings-english-0.4.png`, `expedition-combat-0.4.png`, `large-text-hub-0.4.png` under `docs/qa/screenshots`.

Final APK: `build/android/ashen-covenant-0.4.apk`, 71,464,574 bytes. SHA-256: `456F59712D8ADE3AFF30EAD56160574E8BB18A3F8EACADD81C951508E0E1FB27`.
