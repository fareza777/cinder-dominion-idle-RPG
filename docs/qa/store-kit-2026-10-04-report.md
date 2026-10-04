# Cinder Dominion — English Play Store campaign

Date: 2026-10-04. Game inspected: **0.55.1 / code 58**, repository base **9949b31**. Scope: marketing assets and reproducible source. No gameplay, saves, economy, AdMob configuration, APK or installed launcher icon changes.

## Deliverables

Output: `build/store-kit-2026-10-04`. Archives: `build/Cinder-Dominion-Play-Store-Kit-2026-10-04.zip` and `build/Cinder-Dominion-Remotion-Source-2026-10-04.zip`.

- Object-only crown-and-sword app icon: 512 × 512 RGBA PNG, 569,043 bytes.
- Feature graphic: 1024 × 500 RGB PNG. Citadel key art with a fully armored knight viewed from behind.
- Eight ordered 1080 × 1920 RGB screenshots: battle, Forge, cards, skills, equipment, Shattered Realms, timed Journey and relics.
- Two 30-second Remotion trailers: 1920 × 1080 and 1080 × 1920; 900 frames each at 30 fps, H.264 4:2:0 with stereo AAC at 48 kHz.
- Trailer thumbnail, original art masters, font licenses, English alt text, source/provenance, checksums and an offline preview gallery.
- Editable Remotion project in `marketing/remotion`; literal compositions, local media/fonts and frame-driven animation. `marketing/.gdignore` excludes marketing media and dependencies from Godot imports.

## Direction and truthful claims

The campaign uses **“One more hunt.”** Iron, amber embers, cold teal mist, antique gold and readable serif headlines unify the assets. The icon has no creature or human face. The citadel knight faces away; displayed game heroes and humanoid enemies have enclosed helmets, dark hoods or face coverings. Bandaged animal cards retain their existing in-game art.

Reviewed the implementation ledger and relevant capture/game UI source before producing screenshots. Visible claims are based on implemented content: 21 equipment rarities, 190 monster cards, 16 skills, eight hero choices, 20 campaign locations, level 130, optional guardians, offline work and dungeon journeys. No multiplayer, community raid, public cloud service, ad-free or monetization promises were added.

Screenshots capture actual game UI at 1080 × 2160 and place it in 1080 × 1920 marketing compositions. Crops omit some navigation without repainting UI. A prepared in-memory progressed hero reveals existing content; displayed unlocks/inventory do not represent a new save. Card inventory was reduced from the test fixture's artificial 10,000-per-item stock to a few owned cards before rendering. Region cards were scrolled to the Shattered Realms. The battle screenshot keeps the location title, complete actors and actual attack state.

Battle video uses 240 game-rendered frames at 720 × 1440. The model and battle stage advance manually at 1/30 second, with no altered battle effects or simulated marketing combat. The trailer uses five seconds of this animated footage and seven motion-framed actual UI screenshots. Game UI starts at 1.5 seconds and occupies 26 of 30 seconds; the opening/end card use generated marketing art. The castle panorama is not presented as a playable 3D scene.

The existing original `crown.ogg` score and sword, Forge and reward effects accompany the trailer. No voiceover; English graphical copy works with sound off. Font licenses and both art prompts are included.

## Actual verification

- Godot capture completed and refreshed affected battle/card/world views; no script compile failure. Saves were bypassed by the existing PreviewApp harness.
- Inspected generated crown/citadel, all eight screenshot compositions in a contact sheet, detailed affected views, ten landscape scene frames and six portrait scene frames. Reviewed complete actor framing, covered faces, English copy and headline/UI separation.
- Both Remotion renders completed successfully; TypeScript `tsc --noEmit` passed. No unrelated game regression suite was run for this marketing-only change.
- FFprobe verified both H.264 video streams, dimensions, 30 fps, 900 frames, exact 30-second video/container duration and stereo AAC/48 kHz audio.
- FFprobe reports full-range `yuvj420p` for these 4:2:0 exports; the validator accepts both `yuv420p` and `yuvj420p`. Final encoded MP4 frames were extracted and inspected after rendering.
- Sword SFX align with the captured attack poses. The complete three-second reward chime was retained. The final full Remotion audio timeline was rendered to PCM and muxed into both MP4s with video stream copy, preserving the inspected picture without another video encode.
- Audio decoded successfully: both versions have peak **−11.80 dBFS**, RMS **−22.21 dBFS**, and **zero clipped PCM samples**. This is a level/decode check, not a perceptual listening or LUFS measurement.
- Verified exactly eight RGB screenshots, 1080 × 1920 each, all below 8 MiB; icon RGBA/512/below 1 MiB; banner RGB/1024 × 500. Alt text stays within 140 characters. Manifest records SHA-256 hashes.
- Both ZIP archives passed CRC integrity verification after closing their writers. Source packaging excludes dependencies and build caches.

## Limits and next publication step

This is a local marketing kit. No Play Console or YouTube upload, installation, device playback test or publishing was performed. The existing Godot capture harness still reports 11 leaked objects/five resources at shutdown; these do not prevent the captures but remain a tooling limitation.

The new icon is supplied as a store asset. Applying it to Android launcher resources/export presets should be a separate APK iteration. Future content or UI changes need refreshed capture/copy review.

The landscape video is the primary Play Store preview. Current [Google Play asset guidance](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en) specifies the listing image sizes and a YouTube URL for preview video. Upload and platform acceptance remain unverified.
