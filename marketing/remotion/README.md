# Cinder Dominion — Play Store marketing kit

An English campaign for **Cinder Dominion: Idle RPG**, built around **“One more hunt.”** Fractured iron, controlled ember light, cool stone and large serif headlines connect the icon, feature graphic, eight screenshots and two 30-second trailers.

The interface and battle footage come from the actual Godot game, version **0.55.1 / code 58**. Generated art is used for the object-based icon and promotional atmosphere. Human faces remain hidden by armor, hoods or the viewing angle. No gameplay interface was invented or painted over.

## Delivered formats

| Asset | Format | Size |
| --- | --- | --- |
| App icon | RGBA PNG, opaque background, no baked-in rounded corners | 512 × 512 |
| Feature graphic | RGB PNG | 1024 × 500 |
| Eight screenshots | RGB PNG, ordered 01–08 | 1080 × 1920 |
| Play Store trailer | H.264 / AAC MP4, 30 fps | 1920 × 1080, 30 seconds |
| Portrait trailer | H.264 / AAC MP4, 30 fps | 1080 × 1920, 30 seconds |
| Trailer thumbnail | RGB JPEG | 1920 × 1080 |

Files, the offline preview gallery, alt text and checksums export to `build/store-kit-2026-10-04`. Downloadable kit and editable-source archives are created beside that folder.

## Edit and render

Use Node.js 22 or later. From `marketing/remotion`:

```powershell
npm ci
npm run dev
node render-assets.mjs stills
node render-assets.mjs videos
python package-kit.py
```

The last command requires Pillow and both successful video renders. It exports the icon from its original image, converts listing PNGs to RGB, verifies dimensions and media streams, creates the gallery and packages both archives. Paths resolve relative to this source project. Rendering uses the installed Remotion FFmpeg/FFprobe binaries and a local Chrome Headless runtime.

`src/Root.tsx` contains headlines, crops, scene timings and two literal video compositions: `PlayStoreTrailer` and `PortraitTrailer`. Nine still compositions provide the feature graphic and screenshots. Animation is driven by Remotion frames. Media and licensed fonts are local; rendering requires no paid service.

## Capture genuine gameplay

From the repository root, run Godot 4.7.1:

```powershell
Godot --path . --script tools/capture_store.gd
```

The capture uses a prepared in-memory hero and never loads or overwrites campaign saves. Screenshots render at 1080 × 2160; 240 battle frames render at 720 × 1440. Copy the PNGs from `build/store-capture` to `public/game`, then encode the battle:

```powershell
ffmpeg -framerate 30 -i build/store-capture/battle/frame-%04d.jpg -c:v libx264 -crf 17 -pix_fmt yuv420p -movflags +faststart marketing/remotion/public/game/battle.mp4
```

The script supports `screens-only`, `battle-only` and `battle-still` after `--`. The prepared hero reveals existing content; its unlocks and inventory do not represent a new save.

## Storyboard

| Time | Focus | On-screen hook |
| --- | --- | --- |
| 0–1.5 s | Citadel opening | Your next victory starts with one more hunt. |
| 1.5–6.5 s | Actual animated battle | One more hunt. |
| 6.5–9.5 s | Equipment fusion | Forge your next victory. |
| 9.5–12.5 s | Monster cards | Every enemy hides a prize. |
| 12.5–15.5 s | Professions | Master the craft. |
| 15.5–18.5 s | Equipped hero | Build your own legend. |
| 18.5–21.5 s | Shattered Realms | The road gets darker. |
| 21.5–24.5 s | Dungeon journey | Go AFK. Return stronger. |
| 24.5–27.5 s | Relic growth | The end is only deeper. |
| 27.5–30 s | Crown and title | Your next hunt awaits. |

The trailer mixes actual rendered battle footage with motion-framed game screenshots. Game UI appears at 1.5 seconds and occupies 26 of 30 seconds. It includes the original game music and sword, forge and reward sounds. No voiceover; the campaign remains understandable with sound off.

For audio edits alone, `node render-assets.mjs audio` renders the full soundtrack to `build/trailer-score.wav`. This campaign's final audio pass preserved the complete reward chime and replaced the MP4 audio with AAC using video stream copy, so the inspected picture was not encoded again. A normal `videos` render reproduces the complete updated compositions directly.

## Provenance and listing guidance

`provenance.json` preserves art prompts and source details. Two marketing artworks were generated with OpenAI's image tool. Audio uses the game's existing original assets. Cormorant Garamond and Manrope are accompanied by SIL Open Font License files in `public/fonts`.

Sizes and content follow [Google Play preview asset guidance](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en). The landscape trailer is the primary listing video. Play Console accepts a YouTube URL, so uploading the MP4 and connecting that URL remain separate publication steps. This task creates local assets only.

`marketing/.gdignore` excludes the source project from Godot imports. This campaign does not change game code, saves, ad behavior, installed launcher icons or APKs. Review screenshot claims again when the game's content changes.
