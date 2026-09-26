# 0.21 — Live mastery progress

Mastery panels previously captured victories and rank when opened. Hunts continued behind them, leaving rewards and the milestone action stale.

Collection totals, enemy wins, next rank labels, progress bars, earned rank marks, damage and reward previews now update through the existing modal refresh callbacks. The hunt action updates its label and resolves the batch again when pressed. Locked targets update their requirement and button availability. Maximum mastery offers a 25-fight repeat batch. Singular fragment labels are corrected.

The same dialog remains mounted, preserving scroll. Callback registration is cleared on dismissal. No new save fields, migration, reward changes or art assets.

Collection ordering and available-enemy membership remain a snapshot until reopened, intentionally avoiding moving targets under the player's finger. This iteration does not change queue composition: Hunt still opens the existing activity confirmation before adding work.
