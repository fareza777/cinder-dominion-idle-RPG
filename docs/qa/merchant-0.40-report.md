# 0.40 — Offline rotating merchant

Three distinct limited offers refresh eight hours after the stock is first observed. After a long absence the new stock receives a full eight-hour window when the merchant is opened. Ordinary tools/vials remain permanently available. Offers contain supplies, ingots and potentially Rare accessories, not cards. All transactions use existing gold; trade seals are deferred until the broader card economy is implemented.

Stock tiers require Smithing 30/60/90 and wilds_5/marsh_5/crown_5 respectively. Unlocking a tier does not reroll current stock; eligibility is sampled on the next refresh. There is no guarantee a refresh includes equipment. Each three-item rotation samples distinct entries from the eligible pool without replacement. Consumables remain eligible at later tiers. Rare accessories cost 1,200/4,800/12,000 gold by tier, have one piece per offer and retain normal gear quality/identity behavior. Merchant goods do not include guardian cores, relic essence, socket relics or future cards.

Optional merchant_stock state persists observed time, deadline, revision, tier, offer identity/quantity/quality/price and sold status. A separate RNG avoids perturbing combat loot randomness. A monotonically observed clock prevents ordinary clock rollback from regenerating stock. Buying checks the revision after refreshing, preventing an old button from buying a newly substituted offer. Insufficient gold, full equipment bag or sold-out stock cannot debit funds. Local editable saves/system clocks remain outside a server security model; this is not an anti-cheat guarantee against save editing or repeated deliberate forward-clock manipulation.

Equipment sale is new: sell one unprotected piece for a visible quality-adjusted price after a confirmation screen. Equipped, locked, favorite, preset and loadout gear share the existing protection rule. Repeating a sale for a missing UID fails. Selling a stack removes only one piece. The list shows 20 entries per page. Supply sales remain in Bag with their existing economy. Buy prices exceed sale proceeds for merchant equipment; no paid services or online player market were introduced.

## Verification

- 83 essential checks passed: build/essential40.log.
- Focused merchant40.gd passed stock persistence, rollback stability, tier eligibility, delayed application of unlocks, full-window refresh after absence, stale revision rejection, sold-out/insufficient-gold handling, save round trip, sale protection, duplicate-sale prevention and accessory resale-price bounds.
- UI button activation bought the intended stock index and sold the confirmed gear UID. Three phone screenshots cover stock at 480×960, stock and sale confirmation at actual 360×720 with 1.3 text scale. Screenshots use explicit valid pool entries as a presentation fixture; they do not imply every refresh contains those goods.
- Existing shutdown warnings persist: 11 ObjectDB instances and five resources still in use. No parser/assertion errors in the completed focused run.

## Limits

No physical Android playtest, full campaign economy simulation or price tuning study. No monster cards, stamina or unified status effects yet. Merchant art uses the existing icons/theme rather than new generated art. NPC merchant only, fully offline. Prices and stock progression should be assessed through playtesting alongside later card/stamina work.

Android export reported [DONE] export. APK: build/android/cinder-dominion-0.40.apk, 229605408 bytes. aapt verifies versionCode 40/versionName 0.40.0, legacy package com.ashencovenant.prototype, correct label and arm64-v8a/x86_64. apksigner verification succeeded (v2). SHA256: 5CA78475455FF8B77BCCE0AC4AE1BF964F31B6FEBB545BB1AA8A1C4B64335A79. The known console wrapper remained after its child finished; stopped only identified wrapper PID 26056 after artifact verification. No normal wrapper exit code is claimed.
