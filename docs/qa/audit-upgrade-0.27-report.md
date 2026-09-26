# Build 0.27 verification

## Delivered
Tracked equipment goals, advanced supply orders, XP/time-aware training selection, Apex regional progress, three optional combat doctrines at Bladecraft 25, loadout persistence, tier-scaled bounty rewards, equipment sorting/slot filtering/paging, hunt readiness checklist, bestiary, compact Ascension banner, 16-pose original combat atlas, Ogg music and responsive offline recovery. Full audit scope remains tracked in docs/audit-delivery-roadmap.md.

## Actual checks
- 83 existing essential checks passed after gameplay changes; rerun after final bounty/resume changes also passed.
- audit_checks27 passed: training/crafting/equip states for a tracked sword, optional-field save round-trip, advanced work-order plans, selected-food plan, prior Apex kill inclusion, doctrine damage tradeoffs, and identical 24-hour Apex state for uninterrupted versus time-budgeted simulation.
- Heavy prepared Apex fixture: direct 24-hour simulation measured 17,413 ms on this Windows desktop. This is not an Android benchmark. The new UI yields between simulation budgets rather than reducing total simulation cost.
- resume27: final run used 20 responsive chunks for a one-hour production fixture; cancellation left the original state intact, restart matched the synchronous report/state. Chunk count varies with CPU timing. Main lifecycle cancels pending recovery on pause and retries from unchanged progress after resume.
- Twelve phone captures inspected across 480x960 and 360x800 at 130% font. Added runtime loadout save/apply check for doctrine. Separate focused recapture verified the final dedicated Advanced training dialog. Empty final capture error logs.
- Initial sprite rendering exposed a missing mirrored enemy because of negative destination dimensions. Replaced with a canvas transform; revised capture shows both characters. Toasts from synthetic level changes were suppressed in capture fixtures for unobstructed review.
- Generated atlas inspected and alpha validated: RGBA 1536x1024, 60.14% fully transparent pixels. Four discrete poses for hero and three regional archetypes. New art is used in battle; unique Apex portraits are retained. Not a skeletal rig or a complete animation set.
- Four Ogg resources load as AudioStreamOggVorbis and report 64 seconds. Source WAV total 32,768,176 bytes; encoded Ogg total 1,663,519 bytes. First soundfile encoder attempt failed; final reproducible tool uses the installed imageio-ffmpeg binary and all four resulting streams passed Godot loading/duration checks. No subjective listening claim.
- Godot import/export completed. APK signed and verified; aapt reports com.ashencovenant.prototype, versionCode 27, versionName 0.27.0, arm64-v8a and x86_64. Archive inspection confirms the new combat atlas and all four Ogg resources are packaged; the four source music WAVs are excluded.

APK: build/android/ashen-covenant-0.27.apk

Bytes: 89529914

SHA256: 1D8ADB982EBB562350EE4177FD87F25D48691426C0B58226FD345A81C35D5182

## Compatibility and limits
No catalog IDs removed, save schema remains 1 with validated optional upgrade_goal/doctrine fields. Old loadouts default to Standard training. Existing kills are counted directly; no reward replay or kill rewriting. Default doctrine preserves prior combat values. Bounty reward amounts now scale with gathering/cooking tier, and Apex wins contribute to field milestones: these are intentional economy changes.

No physical Android install, battery/memory measurement, pause-during-catch-up device test, complete doctrine balance sweep or natural milestone playthrough. The responsive recovery path is covered by deterministic state/report checks, not complete mobile lifecycle testing. Catch-up currently excludes processing/loading time from the initial away-time snapshot; lifecycle interruptions during recovery require follow-up validation. Skill training chooses a batch capped at 100 and does not automatically switch recipes after unlocks. Crafted item comparison remains a numeric gear score; hunt readiness is a forecast, not a guarantee. Bestiary encounter advice is a snapshot at opening; hunt plan recalculates.

Further rig animation, unique item effects, milestone talent redesign, weekly variety, richer audio mixing, save migrations and release services remain open in the delivery tracker. No ads, purchases or network service enabled. User saves were not touched by preview/check fixtures.
