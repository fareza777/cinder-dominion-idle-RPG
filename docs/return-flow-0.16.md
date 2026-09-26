# Return flow — 0.16

Welcome back now separates wall-clock time away from the capped simulation interval. The UI explains that rewards depend on tasks actually running, rather than implying all elapsed time generated work. Queue state is shown as running, requiring attention, or no tasks remaining.

The existing offline report gains optional away/capped/levels/queued-before fields. Per-skill level changes are derived from XP before and after simulation; unlocked recipes are read from the catalog. Existing report fields and older-report fallbacks remain. No new mandatory save fields, reward multipliers or duplicate claim actions.

The fixed footer acknowledges the report and routes to onboarding, the current queue or the existing next-action recommendation. Hunt reports, available talent points and ready field-record rewards remain reachable. Item gains and materials spent are separated.

70 essential checks passed, including three additions for real level changes, repeated-return reward idempotency, and distinguishing capped idle time from reward generation. Five isolated phone captures cover progress, blocked work, queue routing, capped idle return and large text. The actual blocked-work footer opens Queue and clears the acknowledged report. Final capture error log empty. Android debug build is for playtesting; no physical-device testing this round.

The user requested continued autonomous iterations after completion. A thread heartbeat named Continue Ashen Covenant development was created with an hourly cadence. Its prompt requires solo coherent iterations, preservation of saves/work, limited meaningful checks, honest reporting and notifications only for completed iterations or actionable failures. It does not authorize public release or paid services.
