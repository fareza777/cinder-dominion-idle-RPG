# Build 0.24 — Focused input and sound room

The visual guide now has four mouse/touch input shields around the actual highlighted control. Its instruction card and Skip stay above the shields. This prevents accidental taps on dimmed navigation while preserving the real target's input. Guidance remains optional and uses the existing persisted preference. Android back navigation is unchanged; keyboard focus navigation is not constrained by these pointer shields.

Settings now opens a sound room with four original 0.22 score tracks and five selectable effect examples. Preview uses the existing two-voice crossfade; a weak reference to the owning dialog restores automatic music selection when the panel closes. Mute preferences are never overridden. No new compositions or audio assets were generated in this iteration.

Verification: 77 essential checks passed. Capture24 injected viewport pointer press/release events: dimmed Bag navigation did not switch page; highlighted Goals, objective action and Begin queued exactly four ore cycles; Skip disabled guidance. Preview selected crown and returned to hearth after dismissal. Four screenshots reviewed at 480x960 and 360x800 with 130% text. Capture was repeated to remove the unrelated queue toast from the sound-room screenshot; final error log empty. Import and git diff checks passed.

Android debug export signed and verified; com.ashencovenant.prototype, versionCode 24, versionName 0.24.0.
APK: build/android/ashen-covenant-0.24.apk
SHA256: F9162527060EAE6726734C6B85EB6E84246A576D00678047B8E7256E4A33330A

No physical Android touch/audio listening test. The score remains synthesized original music; subjective musical quality and device mixing are not established by these checks. No save schema or economy changes. Preview fixtures do not write player saves.
