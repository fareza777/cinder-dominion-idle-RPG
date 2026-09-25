# Future IAP and AdMob boundary

The latest user direction adds AdMob to the earlier cosmetics/expansions business model. This build contains only a disabled integration seam; there are no ad or billing SDKs, live IDs, products for sale, or fabricated successful purchases.

`data/commerce.json` declares two future product concepts (cosmetic cloak, later content expansion) and one optional rewarded placement (refuge supplies). These names are internal draft identifiers, not published store products. Neither proposed product is delivered in this build. `services/commerce.gd` provides async `purchase`, `restore_purchases`, and `request_rewarded` methods. With default configuration, each returns an explicit unavailable result. The core simulation has no dependency on those calls, and no reward or entitlement is granted by a UI click or provider return value.

Before live use, implement the Android providers, real catalog/prices and restore handling; implement verified purchase/reward processing, durable transaction IDs, duplicate rejection and entitlement persistence. Add platform configuration, network permissions, consent handling appropriate to deployment, store identifiers, and cancellation/error UI. Wire optional rewarded placement only after those pieces exist. Enabling a flag or entering an ID alone does not activate a working purchase/ad integration.

Treat provider results as untrusted receipts/events until verified. Keep game rewards separate from display callbacks. If no ad is available or a purchase is cancelled, gameplay must remain usable. Existing daily bounty progress and simulation remain independent of availability of either provider.

Daily boards in this offline preview use a monotonic day_seen bound against device time; unfinished boards carry forward. This is not a trusted economic clock. Server-side time and anti-replay enforcement are still needed for online economy or monetized reward decisions. Save checksums detect accidental corruption, not malicious editing.
