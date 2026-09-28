# 0.42 — Clear rest and resume

The 0.41 rest dialog emphasized time to full recovery and offered Resume even when the next hunt could not start. This made a short recovery threshold look like a several-hour wait and offered an action that only produced an error.

The dialog now leads with the queued enemy, required reserve, missing stamina and live remaining rest time. A separate full-recovery estimate remains secondary. Players are explicitly told they need enough for the next hunt, not a full bar. Resume is disabled until stamina and other requirements are met, and hidden during battle or when no hunt leads the queue. It updates without reopening the dialog. Successful activation closes the dialog and starts the queued hunt. Explore says Resting while blocked and Resume when ready. Queue warnings use the same readiness information. The detailed rules live in How stamina works.

The command layer independently rejects premature, already-running and non-hunt resume requests before mutating pause state. Recovery never starts a manual hunt by itself. Stamina rates, reserves, rewards, combat balance, card odds and saved-state format are unchanged. Existing rewarded assistance retains its existing behavior. No new art or paid services.

## Verification

- 83 essential checks passed: build/essential42.log.
- tests/rest42.gd passed: 19 stamina with one minute of recovery correctly needs two more points/five minutes for Ash Rat's 21-point reserve; premature resume preserves the entire saved state; live UI changes from disabled to ready after that recovery; no automatic manual hunt; activating the actual button starts combat and dismisses the modal; duplicate resume fails; an empty queue hides Resume; save round trip remains valid.
- Three rendered 360×720 phone captures at 130% text were reviewed: waiting, ready and no queued hunt. No text overlap observed; the waiting dialog scrolls to additional guides. No physical Android playtest.
- Existing shutdown warning remains: eleven ObjectDB instances/five resources in use. No parser/assertion failures in the completed runs.
- Full campaign pacing, real device performance and cleanup of the existing resource warnings remain outside this bounded iteration. The countdown is simulation-based resting time; it is not a promise of recovery while fighting.

## Android artifact

Export reported `[DONE] export`. APK: build/android/cinder-dominion-0.42.apk, 231,681,332 bytes. aapt confirms unchanged package com.ashencovenant.prototype, versionCode 42/versionName 0.42.0, correct public label and arm64-v8a/x86_64. apksigner v2 verification succeeded. SHA256: `6EA375D5C20ABDAB41F2B0C2EE203CD80AFD1675BCFC87338E30DC7359E2B317`.

The known console wrapper remained after the export child finished; only verified wrapper PID 22464 was stopped after APK verification. No normal wrapper exit code is claimed. Existing duplicate UID warnings refer to the ignored build/admob source copy; build/ and docs/ remain excluded from export. Installation/upgrade on a physical device was not tested.
