# Ashen Covenant — depth and presentation review, 0.5

Reviewed the existing Godot implementation, content tables, progression rules and rendered phone-sized screens. This was a source review with focused scripted interaction, not a claim of a long player session or measured retention.

## Findings addressed

| Priority | Finding | Change and player benefit |
| --- | --- | --- |
| High | Starter enemies could outperform dangerous expeditions for relic fragments. Higher numbers alone did not justify moving on. | Guaranteed fragments now scale by region and tier: Wilds 8–40, Sanctum 12–60, Crown 16–80. The relic screen compares unlocked hunting grounds using the current build, expected time, food and fragment yield. |
| High | Farming links always sent players to a fixed starter enemy, ignoring their equipment and unlocked content. | Hunting grounds sort lower-risk options before estimated yield. Each route proposes the victories needed for the next rank, capped at 100 per proposal. Exact fragment rewards are separate from approximate rates. |
| High | Expedition guardians shared portraits and the same empowered hit. Regions lacked combat identity. | Three original guardian portraits and three distinct third attacks: Bramble Crush pierces half armor, Drowned Hymn restores Oracle health, Final Toll delivers a larger burst. Preparation and combat countdowns name the actual threat. |
| High | Long dialogs buried the action beneath explanation, especially with large text. | Begin, Gather & craft and Begin this order stay in a fixed footer while details scroll. The first objective button was exercised and produced exactly four ore. Quick-start copy now explains that count buttons start work immediately. |
| Medium | Preparation buried risk beneath rewards, and full-width portrait cropping removed the guardian's face. | A compact portrait/lore header is followed by the forecast and special attack, then rewards. Face framing was corrected after inspecting the first render. |
| Medium | Food explanations omitted Emberheart's healing bonus. | A shared helper supplies both actual combat healing and preparation/help text. Oracle recovery displays the amount actually restored. |
| Medium | A single combat event erased simultaneous enemy healing or player damage. Long catch-up could replay obsolete hit numbers. | A bounded transient event list displays recent damage and healing separately, colors healing green, and ignores events older than one simulation second. No reward or save logic depends on visual effects. |
| Medium | Work orders explained XP without showing the resulting level; four large selector buttons consumed space. | Compact order selector, projected skill levels and readable hour/minute estimates make offline work easier to choose. |

## Farming example

The inspection fixture uses rare iron equipment and 750 Might XP. Its estimated Ashfang route is 34.3 fragments/minute from Wilds tier 1 versus 30.0 from Ash Rats. Previously the same Wilds reward was two fragments; it is now eight. These are analytical estimates, not measured production rates or a guarantee that every higher tier is always optimal. Gear, accuracy, current health, food, enemy recovery and fighting style affect the forecast. Finding a productive repeatable tier before pushing the next tier is intentional.

The forecast is bounded and inexpensive. It approximates average skill/critical damage and incoming attacks; it does not model every potion activation, food timing or miss sequence. Exact combat continues to use the existing deterministic event simulation. A single food estimate does not guarantee supplies for an entire queued hunt.

## Journey and return loop

The opening remains ore → ingots → wood → sword → equip → rats. Existing guidance then leads through story hunts, Smithing and the Bellkeeper. The new iteration strengthens the next loop: choose a relic goal → compare hunting grounds → prepare food/build → repeat a suitable tier → awaken the relic → attempt a harder guardian. Work orders support supply preparation between visits. Existing carry-forward bounties do not erase unfinished progress or punish a missed day.

Save schema remains version 1 with optional progression data; existing campaigns remain readable. Upgrading changes expedition payouts and future guardian attacks, including resumed fights. No paid power, live purchases or advertisements were enabled.

## Remaining production gaps

- Presentation still uses illustrated portraits and interface animation. Full character animation, richer encounter staging, broader music/sound direction and authored cinematics remain substantial work.
- Fifteen expedition tiers share three regional guardian identities. More encounter variety, equipment interactions and campaign chapters are needed for a full commercial RPG.
- Long-term balance, session pacing and return rates need actual player feedback. No retention improvement or AAA quality is asserted from this review.
- Touch ergonomics, thermal behavior, accessibility and performance across physical Android devices have not been certified in this iteration.
- Billing, cosmetic/expansion entitlements, optional rewarded advertising, server-authoritative economy and cloud saves remain outside this build.

Evidence and package details: `qa/polish-0.5-report.md`.
