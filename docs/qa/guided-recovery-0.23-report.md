# 0.23 — Guided material recovery

The beginner focus previously disappeared when missing ingredients replaced Begin with a planner action. It also reported active crafting as blocked after ingredients were reserved. This iteration follows the planner and queue-management actions explicitly, distinguishes an already queued goal from unrelated work, and only reports missing requirements as a blockage when no cycle or fight is active.

Existing recommended-task dialogs now place Manage existing queue in the fixed footer when an order is already queued. No task is cancelled or overwritten by opening it. Missing-material planning remains the existing confirmed Gather & craft operation. The current-cycle message distinguishes reserved materials from requirements for additional cycles.

Verification: 77 existing essential checks passed. Focused capture23 walked a missing-ore plan through real UI actions and model advancement to two ingots, verified a cycle with reserved ingredients still reads Working automatically, and opened queue management without changing the queued task. Five phone screenshots reviewed at 480x960 and narrow 360x800 with 130% guidance text. Final capture log is error-free; import and diff checks passed. Capture repeated after correcting the additional-cycle wording found in visual review.

Android debug export signed and verified; package com.ashencovenant.prototype, versionCode 23, versionName 0.23.0.
APK: build/android/ashen-covenant-0.23.apk
SHA256: 772E5ABA674A8B2FEDFA3479B37C5CDDFD1FFE2B816B501453047F89F61CC7E6

No physical Android test. Planner errors for locked recipes still use the existing explanatory screen; full queue editing is not guided. No save schema, economy, music or artwork changes. Preview uses an isolated in-memory campaign and does not write user saves.
