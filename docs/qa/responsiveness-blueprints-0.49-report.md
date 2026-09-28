# 0.49 — Responsiveness, card art and blueprint discovery

## Measured navigation

Same desktop, Godot 4.7.1 compatibility renderer / GTX 1070, prepared endgame Warden fixture, no save writes. Three rounds of five tabs. Build time measures synchronous page construction; ready time includes the following rendered frame. It is not a physical Android frame-rate measurement.

| Tab | Before warm construction | After warm construction | After warm ready |
| --- | --- | --- | --- |
| Stronghold | 56–60 ms | 12 ms | 22–23 ms |
| Bag | 128–140 ms | 33–34 ms | 58–61 ms |
| Hero | 57–58 ms | 16 ms | 28 ms |
| Skills | 57–62 ms | 17 ms | 30–32 ms |
| Explore | 309–313 ms | 30–33 ms | 47–50 ms |

Benchmark: tests/navigation49.gd. Before/after raw logs retained in build/profile49-before.log and build/profile49-final.log (ignored local build output). Shared asset caching prevents unload/reload across destroyed pages; this trades bounded retained texture memory for speed. First Explore construction still ~199ms, first Bag ~136ms. Dynamic text evaluates at most every150ms and skips offscreen nonempty labels; initial text is synchronous. Full battle forecasts run in hunt preparation instead of each enemy list row. Supplies render at most30 per page; equipment pagination is unchanged.

## Blueprint rules (internal design values, not shown in game)

Ten masterworks each have one existing recipe guardian as their eligible source. Independent persisted RNG rolls 0.01% per eligible victory; a learned recipe cannot drop again. Highest-tier merchant stock has a 1% chance per normal eight-hour rotation to replace one ordinary offer with an unlearned blueprint; prices20–110 Platinum. Opening the merchant does not reroll stock. Buying learns the recipe permanently; skill, materials and commission costs still apply. Existing crafted/owned/gained masterworks remain learned. Boss kill counts alone do not grandfather unlocks. Seven earlier guardian relic recipes retain guaranteed first-victory unlocks.

Collection and crafting/training/source/upgrade entry points hide unlearned masterworks. Known blueprint items use the existing parchment/commission art. Rat and Hound cards use their existing bandaged battle art exactly; no new image generation.

## Verification

- tests/blueprints49.gd: hidden craft and planner rejection, actual deterministic rare drop, no duplicate/wrong-enemy drop, old ownership retention, save round trip and optional RNG validation, rare merchant appearance, stock stability, insufficient funds, successful purchase and sold-out rejection. Passed.
- tests/essential_checks.gd: all83 checks passed after updating the expected catalog count from267 to277; initial run failed only the old count assertion.
- tests/capture49.gd: exact card/battle atlas identity, hidden/learned collection assertions, unknown masterwork absent from All recipes, supply pagination action. Phone captures412x892 and360x800 at130% text. Rat/Hound, discovered collection and both supply layouts visually inspected.
- tests/onboarding47.gd: six-step real-pointer walkthrough, shell rebuild, completion, restored navigation, persisted dismissal and narrow Skip passed.
- Editor import clean; git diff whitespace check passed. Capture runs retain known shutdown warnings:11 ObjectDB instances /5 resources. No physical Android test or exhaustive all-device profiling.

## Android package

build/android/cinder-dominion-0.49.0.apk,249089848 bytes. Existing package com.ashencovenant.prototype; versionName0.49.0/versionCode50; arm64-v8a and x86_64. APK Signature Scheme v2 verifies. SHA256:84194C7E3C690B70679ED0E5FE416A0AFE838D2916556F6FDD080D75D71A36C1.

Exporter reached [DONE] export and child exited. The identified lingering console wrapper PID3452 was stopped; no natural export-exit-zero claim. Existing stone/iron visuals retained. APK is debug, not a public release.
