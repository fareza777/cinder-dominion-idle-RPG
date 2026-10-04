"""Format export, verification and packaging. Does not repaint or edit artwork."""
from pathlib import Path
import hashlib
import html
import json
import os
import shutil
import subprocess
import zipfile
from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "build/store-kit-2026-10-04"
KIT_ZIP = ROOT / "build/Cinder-Dominion-Play-Store-Kit-2026-10-04.zip"
SOURCE_ZIP = ROOT / "build/Cinder-Dominion-Remotion-Source-2026-10-04.zip"
OUT.mkdir(parents=True, exist_ok=True)

shots = [
    ("One more hunt.", "A hooded hero battles the Drowned Sovereign in the cathedral, with health, skill and queue controls."),
    ("Forge your next victory.", "The equipment Forge shows a Star Blade and duplicate fusion requirements across 21 rarity tiers."),
    ("Every enemy hides a prize.", "Monster cards for Ash Rat, Hollow Hound and Grave Thrall show their compatible equipment slots."),
    ("Master the craft.", "The Professions screen shows gathering, crafting and arcane groups, including Woodcutting and Mining."),
    ("Build your own legend.", "A fully hooded armored hero is surrounded by ten equipment slots, with build and legacy tabs."),
    ("The road gets darker.", "Explore lists Drowned Cathedral, Glassfire Caldera and Winter Observatory in the Shattered Realms."),
    ("Go AFK. Return stronger.", "An Iron Ossuary dungeon journey shows remaining time, the next chamber and the chosen vault route."),
    ("The end is only deeper.", "The relic screen shows Ashfang growth, ascensions and a route to fragments and essence."),
]

# Required store format exports. Resizing/conversion only; compositions are rendered by Remotion.
icon = Image.open(HERE / "public/art/crown-original.png").convert("RGBA")
icon.resize((512, 512), Image.Resampling.LANCZOS).save(OUT / "app-icon-512.png", optimize=True)
for name in ["feature-graphic-1024x500.png"] + [f"screenshot-{i:02}.png" for i in range(1, 9)]:
    image = Image.open(OUT / name).convert("RGB")
    image.save(OUT / name, optimize=True)
Image.open(ROOT / "build/trailer-preview-866.png").convert("RGB").save(
    OUT / "trailer-thumbnail-1920x1080.jpg", quality=96, subsampling=0
)
for folder in ["masters", "licenses"]:
    (OUT / folder).mkdir(exist_ok=True)
shutil.copy2(HERE / "public/art/crown-original.png", OUT / "masters/app-icon-original.png")
shutil.copy2(HERE / "public/art/citadel-original.png", OUT / "masters/citadel-key-art.png")
for source in (HERE / "public/fonts").glob("*-OFL.txt"):
    shutil.copy2(source, OUT / "licenses" / source.name)
shutil.copy2(HERE / "kit-readme.md", OUT / "README.md")
shutil.copy2(HERE / "provenance.json", OUT / "provenance.json")

def asset(name, **extras):
    file = OUT / name
    record = {"file": name, "bytes": file.stat().st_size,
              "sha256": hashlib.sha256(file.read_bytes()).hexdigest(), **extras}
    if file.suffix in [".png", ".jpg"]:
        with Image.open(file) as image:
            record.update(width=image.width, height=image.height, mode=image.mode)
    return record

assets = [asset("app-icon-512.png", role="app_icon", alt="A fractured iron crown and sword glow with an ember core against a cold dark background."),
          asset("feature-graphic-1024x500.png", role="feature_graphic", alt="Cinder Dominion: Idle RPG beside an armored knight facing a vast ember-lit citadel.")]
for i, (title, alt) in enumerate(shots, 1):
    assert len(alt) <= 140
    assets.append(asset(f"screenshot-{i:02}.png", role="screenshot", order=i, title=title, alt=alt))
assert len(list(OUT.glob("screenshot-*.png"))) == 8
assert assets[0]["mode"] == "RGBA" and assets[0]["width"] == assets[0]["height"] == 512
assert assets[0]["bytes"] <= 1024 * 1024
assert assets[1]["mode"] == "RGB" and (assets[1]["width"], assets[1]["height"]) == (1024, 500)
for record in assets[2:]:
    assert record["mode"] == "RGB" and (record["width"], record["height"]) == (1080, 1920)
    assert record["bytes"] < 8 * 1024 * 1024

probe_candidates = list((HERE / "node_modules/@remotion").glob("compositor-*/ffprobe*"))
ffprobe = shutil.which("ffprobe") or str(next(p for p in probe_candidates if p.name in ["ffprobe.exe", "ffprobe"]))
videos = []
for name, size in [("trailer-landscape-1920x1080.mp4", (1920, 1080)),
                   ("trailer-portrait-1080x1920.mp4", (1080, 1920))]:
    file = OUT / name
    result = subprocess.run([ffprobe, "-v", "error", "-show_streams", "-show_format", "-of", "json", str(file)],
                            check=True, capture_output=True, text=True)
    metadata = json.loads(result.stdout)
    video = next(s for s in metadata["streams"] if s["codec_type"] == "video")
    audio = next(s for s in metadata["streams"] if s["codec_type"] == "audio")
    assert (video["width"], video["height"]) == size
    # FFprobe calls full-range 4:2:0 yuvj420p; both are compatible H.264 4:2:0 exports.
    assert video["codec_name"] == "h264" and video["pix_fmt"] in ["yuv420p", "yuvj420p"]
    assert video["avg_frame_rate"] == "30/1" and int(video["nb_frames"]) == 900
    assert audio["codec_name"] == "aac" and int(audio["channels"]) == 2
    assert abs(float(metadata["format"]["duration"]) - 30) < 0.1
    record = asset(name, role="trailer", width=size[0], height=size[1], duration_seconds=30, fps=30,
                   video_codec="h264", audio_codec="aac")
    assets.append(record)
    videos.append({"file": name, "video": video, "audio": audio, "duration": metadata["format"]["duration"]})
assets.append(asset("trailer-thumbnail-1920x1080.jpg", role="video_thumbnail",
                    alt="The fractured ember crown beside the Cinder Dominion: Idle RPG title."))

manifest = {"game": "Cinder Dominion: Idle RPG", "date": "2026-10-04", "locale": "en",
            "campaign": "One more hunt.", "game_version": "0.55.1", "assets": assets}
(OUT / "asset-manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
audio_report = ROOT / "build/store-audio-review.json"
(OUT / "verification.json").write_text(json.dumps({
    "required_images_passed": True, "screenshot_count": 8, "icon_below_1024_kib": True,
    "listing_images_rgb": True, "screenshots_below_8_mib": True, "trailers_900_frames_each": True,
    "videos": videos,
    "audio_decode_review": json.loads(audio_report.read_text(encoding="utf-8")) if audio_report.exists() else [],
    "review": "Actual UI crops, eight screenshots, generated icon/banner and scene frames were inspected visually. Prepared capture only; no Play Console upload or physical-device validation. Existing Godot capture shutdown leak warnings remain."
}, indent=2), encoding="utf-8")

cards = []
for i, (title, alt) in enumerate(shots, 1):
    name = f"screenshot-{i:02}.png"
    cards.append(f'<article class="shot"><button class="image-button" data-full="{name}" aria-label="View screenshot {i}">'
                 f'<img loading="lazy" src="{name}" alt="{html.escape(alt, quote=True)}"></button>'
                 f'<div class="number">{i:02}</div><h3>{html.escape(title)}</h3><div class="downloads">'
                 f'<a href="{name}" download>Save PNG</a><span class="muted">1080 × 1920</span></div></article>')
gallery = (HERE / "gallery.html").read_text(encoding="utf-8").replace("<!-- SCREENSHOT_CARDS -->", "\n".join(cards))
(OUT / "index.html").write_text(gallery, encoding="utf-8")

with zipfile.ZipFile(KIT_ZIP, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for file in sorted(OUT.rglob("*")):
        if file.is_file(): archive.write(file, file.relative_to(OUT))
with zipfile.ZipFile(SOURCE_ZIP, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for directory, folders, files in os.walk(HERE):
        folders[:] = sorted(f for f in folders if f not in {"node_modules", "out", "dist", ".cache", "__pycache__"})
        for name in sorted(files):
            file = Path(directory) / name
            archive.write(file, file.relative_to(ROOT))
    archive.write(ROOT / "tools/capture_store.gd", "tools/capture_store.gd")
    archive.write(ROOT / "marketing/.gdignore", "marketing/.gdignore")
    report = ROOT / "docs/qa/store-kit-2026-10-04-report.md"
    if report.exists(): archive.write(report, report.relative_to(ROOT))
for file in [KIT_ZIP, SOURCE_ZIP]:
    # Verify after closing the writer so buffered compressed data is completely flushed.
    with zipfile.ZipFile(file, "r") as archive:
        assert archive.testzip() is None, str(file)
print(json.dumps({"images": 10, "screenshots": 8, "trailers": 2,
                  "kit_zip_bytes": KIT_ZIP.stat().st_size, "source_zip_bytes": SOURCE_ZIP.stat().st_size,
                  "verification": "Dimensions, color modes, file sizes, video/audio streams and ZIP integrity passed."}))
