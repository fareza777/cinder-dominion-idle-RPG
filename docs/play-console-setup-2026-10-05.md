# Play Console setup — 2026-10-05

## App record

- **Name:** Cinder Dominion: Idle RPG
- **Package:** `com.ashencovenant.prototype`
- **Developer account:** `7590575640597683388`
- **Play Console app id:** `4973749951168274105`
- **Default language:** English (United States)
- **Type:** Game
- **Pricing:** Free
- **Automatic protection:** enabled

The app record and the closed Alpha track are configured in Google Play Console. No production release was started or published.

## Release submitted to closed testing

- **Track:** Closed testing — Alpha (`4700276459474732172`)
- **Status at verification:** Active; release `0.56.0 Closed Test` is **in review**
- **Version code/name:** `59` / `0.56.0`
- **AAB:** `build/android/cinder-dominion-0.56.0.aab`
- **SHA-256:** `2F660F8B6FF52824E0F7E3035112C3113115D2C340394F7990EE1EADA402C88F`
- **Targeted regions:** 178 countries/regions
- **Tester access:** four Google Groups copied from the Vocatim Alpha setup
- **Feedback channel:** `fajar.mreza@gmail.com`
- **Release notes:** first closed-test build; refined idle progression/offline reports; expanded hunt, forge, cards, relics and Journey; improved onboarding, battle readability and phone layouts.

The release and the related listing/declaration changes were submitted through **Submit 16 changes for review**. Google’s automated checks were still running at the time of verification; the only known quality warnings are the missing deobfuscation mapping and native debug-symbol files. These do not block this closed-test submission.

The tester join URL is shown by Play Console as:

`https://play.google.com/apps/testing/com.ashencovenant.prototype`

Play Console keeps the link disabled until Google finishes publishing the test release. The track currently reports zero testers opted in; the production eligibility requirement still shows 12 testers active for 14 continuous days.

## Store listing submitted for review

- **App name:** `Cinder Dominion: Idle RPG`
- **Short description:** `Fight, forge, and grow through a dark fantasy idle RPG.`
- **Full description:** stored in `docs/store-listing-2026-10-05.md`
- **Icon:** `build/store-kit-2026-10-04/app-icon-512.png`
- **Feature graphic:** `build/store-kit-2026-10-04/feature-graphic-1024x500.png`
- **Phone screenshots:** `screenshot-01.png` through `screenshot-08.png`
- **Trailer:** [Unlisted YouTube trailer](https://youtu.be/4qJeAsRPd_c)
- **AI asset declaration:** all ten uploaded listing assets were individually marked as created or edited using AI.

The English default listing is complete and appears in Publishing overview as part of the changes in review.

## Completed app-content declarations

The following declarations were saved for the app and included in the review submission:

- privacy policy URL
- sign-in details: no sign-in required
- contains ads: yes
- content rating
- target audience: 13–15, 16–17, and 18+
- data safety
- government apps: no
- financial features: none
- health features: none
- advertising ID usage for advertising/marketing
- role-playing game category and Google Play Games for PC form factor

## Public policy files

- Privacy policy: https://raw.githubusercontent.com/fareza777/cinder-dominion-idle-RPG/main/privacy-policy.html
- App-ads reference: https://raw.githubusercontent.com/fareza777/cinder-dominion-idle-RPG/main/app-ads.txt

## Remaining release gates

- Google review and automated checks must finish before the closed-test link becomes usable.
- Testers must opt in and remain active for the required 14-day period before production eligibility can be evaluated.
- The app still uses official Google test ad IDs. Live AdMob IDs, consent configuration and a production Play Billing adapter are not configured.
- `remove_ads` is represented in the app contract at USD 4.99, but the native billing adapter is intentionally disabled until production billing is configured.
- No production rollout, public listing publication or paid-service activation has been performed.
