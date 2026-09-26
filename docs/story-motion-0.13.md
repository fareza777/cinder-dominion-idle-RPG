# Story, motion and leveling — 0.13

## Delivered

Seven short English story chapters follow actual campaign milestones. Chapters have an explicit next-action section; locked chapters show their unlock condition without story spoilers. Existing saves derive access from their recorded progress. No new required save data or duplicate chapter rewards.

An original 1536×1024 three-panel narrative atlas was generated with the built-in image_gen tool, inspected, copied into project assets and integrated into the journal. Full prompt is in art-prompt-0.13.md and asset provenance is in assets/manifest.json. Existing portraits and item icons remain in use; this is not a claim of a complete art replacement.

Guardian special attacks emit a presentation-only cast event. Wilds draws roots, Sanctum draws recovery waves, and Crown draws a shock ring. A cast label remains in reduced-motion mode; moving cast effects are disabled. Style attack labels now distinguish Cleave, Ward and Rend. Damage, attack timing and reward rules are unchanged.

Dialogs fade in when motion is enabled. Buttons gain pressed feedback and wrapped long labels. Visual review caught collapsed header buttons from wrapping; bounded minimum widths corrected that before export. Existing focus styles and touch-height minimums are retained.

Skill pages show next-level XP, a progress bar and the next recipe unlocks from the catalog. The training action opens existing preparation with a disclosed 100-cycle batch cap. Live level-ups show concise unlock feedback and refresh the selected skill page; initial load suppresses old level notifications. Chapter unlocks use a brief optional-journal notification, not a blocking modal.

## Verification and limits

60 essential checks passed, including three new story/catalog checks. Eleven isolated phone captures cover menu, inventory icons, Refuge, opening, locked chapter, beacon chapter, leveling, level-up toast, guardian cast, reduced motion and large text. Captures verified the milestone toast and revealed the button regression that was fixed. Final capture error log empty.

Animation remains procedural portrait presentation rather than skeletal characters. Screenshots verify rendered states, not frame pacing on phones. Android output is debug signed; no physical-device performance, full accessibility audit, voiceover, expanded combat economy or long-term balance certification was performed.
