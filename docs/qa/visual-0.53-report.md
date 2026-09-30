# 0.53 — Enemy identities, page audit and collectible card frames

## Delivered

The original 120 enemy actor mappings are unchanged. The 70 Shattered Realms monsters now have distinct generated regional identities: seven transparent atlases, ten creatures and two poses per creature. New silhouettes include drowned bell armor, obsidian, ice instruments, silver roots, meteor fragments, porcelain regalia and celestial metal. Faces remain sealed, blank or fully bandaged. The porcelain sheet was edited to remove facial anatomy and separate touching figures. Exact generation prompts and sources are recorded in `docs/art-0.53-provenance.json`.

Battle, queue, portraits and cards share those identities. Alpha measurements and cached UV meshes isolate neighboring figures without changing source PNG pixels. Pose pairs retain consistent battle proportions and grounded feet; small scavengers and larger rulers use different scales. Portraits use full silhouettes rather than cropping heads.

User requested prettier cards during this iteration, then requested removal of visible rarity labels. All 190 card icons now use clipped-corner metal borders, fine inset lines, corner ornaments, rarity color accents and a subdued environmental backdrop, with no rarity text. Detail illustrations are centered within a larger frame; effects and compatible equipment slots remain outside the illustration. Collection rows show name, allowed slots, copies in the bag and attached copies. Filters include discovered locations, bag ownership and attachments. The four existing card categories (Rare, Epic, Legendary, Mythic), discovery rules, effects, prices and drop probabilities are unchanged; probabilities are not shown.

## Page-by-page audit

| Page / area | Result and changes | Remaining recommendation |
|---|---|---|
| Splash / main menu | Reviewed after transition settles; existing emblem and dark scenery retained. | Add device loading measurements before adding heavier effects. |
| Cinematic / welcome | English copy readable; footer actions remain clear. | Cinematic is illustrated scenes, not fully animated film. |
| Character creation | Reviewed name field, eight choices, selected portrait and stat tradeoff. | A wider selected-character composition could make better use of the portrait space. |
| Stronghold | Added defeated-ruler count and useful post-completion guidance. Existing next-objective card retained. | Late-game recommendations could prioritize an explicit target build. |
| Explore world selector | Generic world-map entry now opens the current location selector. | A compact optional list view could reduce scrolling across many open locations. |
| Local hunts / battle | Collapsed preparation clutter; removed redundant legacy destination links; new monster art and grounded battle figures reviewed. | Existing two-pose battle system still benefits from bespoke timing for creature families. |
| Skills | Replaced three permanent service buttons with one Tools & equipment entry; selected recipes no longer repeat the large professions header. | New profession cards still share some scenery; dedicated tool illustrations would distinguish them further. |
| Forge | Added a paged fusion equipment picker with equipped weapon first, plus explicit refinement access. | Add search if gear inventories make eight-item pagination cumbersome. |
| Bag | Existing grid/filter inspected at narrow size and large text; cards inherit the new frames. | Surface sorting and card-only browsing more prominently. |
| Hero equipment | Retained approved stone rails and complete hero portrait. | Clearer comparative accessory bonuses could help build decisions. |
| Hero Build | Replaced raw accumulated combat XP with XP remaining; level 130 displays Mastered. | Add concise explanations for interacting status effects. |
| Hero Legacy / talents | Navigation and readable tree reviewed. | Talent nodes still use numbers; meaningful ability illustrations are a useful next art task. |
| Relics / Runeforge | Existing art, active selection, costs and previews reviewed. | Avoid redundant projections when the selected rune is already equipped. |
| Bestiary | Replaced obsolete fixed region filter with discovered locations, including all new realms. | Show concise combat identity alongside basic stats. |
| Monster Cards | Redesigned collection rows and frames; added location/ownership filters. | A rarity sort can follow without revealing undiscovered cards. |
| Masterworks | Hidden-blueprint logic retained; discovered recipes reviewed. | Unique equipment illustrations remain uneven in detail. |
| Merchant | Stock, price and purchase actions reviewed. | Some accessory art remains simple; a focused replacement atlas would help. |
| Dungeon journeys | Shortened repeated introduction; route requirements and departure actions retained. | Journey outcomes are timed resolution, not individually animated dungeon rooms. |
| Story journal | Existing 18-chapter journal reviewed; regional stories remain in their locations. | Unify discovered regional lore into the journal without adding mandatory narrative. |
| Contracts / Depths | Progress, reward actions and risk text reviewed. | More distinctive optional-boss encounter presentation. |
| Work orders / queue | Existing task purpose and action reviewed; queue uses new enemy figures. | Preset work orders still favor early food/materials; add progression-aware endgame orders. |
| Settings / About | Display, Audio, Save and About tabs reviewed; version updated. | Physical-device accessibility and audio mix review remain outstanding. |

## Actual verification

- Rendered and visually reviewed all 140 new poses in seven galleries. Measured source regions are non-empty and within expected bounds. All 70 new actor pairs are unique; the original 120 mappings match the prior commit.
- Reviewed 43 page/dialog states at phone sizes 412×892 and 360×800 with 130% text, then 15 focused final-state captures including creation, Forge, new cards, new Bestiary, small/ruler battle figures and large-text pages.
- Real pointer input exercised refinement entry, fusion target selection, profession services, location entry and a specific new card detail. The first Forge check exposed poor equipped-item ordering; weapon-first ordering was added and the check passed. A too-broad card selector initially hit the location dropdown; it was corrected to the exact card name and the detail action was asserted.
- 83 essential simulation checks and 40 expansion checks passed. This is a presentation/navigation iteration; no economy or save-schema migration added.
- Whitespace and changed-source encoding checks passed.
- Five final card captures reviewed after removing rarity text, including original Rat art, a new realm card, collection filters and 130% text. Rarity-label assertions passed.

## Limitations

No physical Android play/performance verification or full-campaign balance claim. Existing capture-harness shutdown warnings remain (11 ObjectDB instances / 5 resources); successful interactions have no runtime script errors. Original 120 enemy art and much equipment/material art are retained. This audit covers major pages and representative states, not every item dialog and scroll position. Remaining recommendations above are not claimed implemented. No public publication, paid-service activation or AAA/SSS completion claim.

## Package

Android debug version 0.53.0 / code55, package `com.ashencovenant.prototype`, arm64-v8a/x86_64. APK: `build/android/cinder-dominion-0.53.0.apk`,315838091 bytes. APK Signature Scheme v2 verified. Inspected the final archive for190 actor mappings,seven imported realm atlases and the new compiled card renderer. SHA256: `4EF3BB13154C480A296434BA7C41B1BA8238DC1E1759DFC2B1145E1FAB4D0C7A`.

Final exporter reached `[DONE] export`; its child exited but the identified console wrapper remained and was stopped after verification. No natural export-process exit-zero claim. Intermediate exports were superseded after the user's card styling and rarity-label revisions; only the final package above is delivered.
