# 0.22 — Guided onboarding and original audio

## Intent
Make the first session unambiguous through actual highlighted controls, short English instructions and visible automatic progress. Preserve the action-first direction, optional guidance, existing saves and the dark fantasy identity.

## Guidance
New players choose Show me the way or Explore on my own. The overlay follows six existing Journey goals: four ore, two ingots, one log, forge, equip and three Ash Rats. It locates controls by explicit metadata, draws four dimmed regions around the target, a gold focus outline and an arrow, then positions its instruction card above or below the target. The highlighted real button remains clickable. Other navigation remains usable, with Skip guidance always available; unrelated dialogs temporarily hide guidance.

Goals opens the objective, its action opens the existing task confirmation, Begin starts the real queue, and the activity bar becomes the focus while working. Equipment confirmation is highlighted directly. Victory completes the beginner guide and explains the repeatable gather/upgrade/hunt loop. Layout follows actual control geometry, large text and reduced-motion preference.

The optional experience.coach_active boolean persists only opt-in guidance; the save validator checks its type. Old saves remain valid. Replay resumes the current objective, never resets resources or creates a second queue. No economy changes.

## Sound
Original synthesized arrangements, reproducible with tools/make_score_022.py; no external samples, licensed recordings, paid tools or services. Four 64-second, 32 kHz stereo tracks with changing chords, bowed harmonics, plucks, bells, circular reflections and regional percussion. Maximum mastered peaks are below -8 dBFS. WAV streams loop and two music voices crossfade over two seconds using equal-power gain. Unknown combat regions fall back to wilds instead of fading to silence.

Nine cue assets include action, guide, equip, forge, strike, hurt, reward, victory and defeat. Four SFX voices allow overlapping cues. Hit sounds are restricted to recent actual damage events, with a short throttle, excluding misses and healing. Settings include an SFX preview; both sliders preserve their values. Pause suspends both score voices and stops SFX.

## Scope and limitations
This is a guided first-session upgrade, not a fully guided endgame. After the first hunt, normal Goals/Farm systems take over. Guidance dims visually without locking the entire interface. Music is an original synthesized score, not a recorded orchestra. Device speakers, headphone balance and subjective musical quality require listening on Android. No physical Android test was performed.
