"""Encode existing original music; keep source WAV files for reproducibility."""
from pathlib import Path
import subprocess, imageio_ffmpeg
root = Path(__file__).resolve().parents[1] / 'assets/audio'
for name in ['hearth', 'wilds', 'sanctum', 'crown']:
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-v', 'error', '-i', str(root / (name + '.wav')), '-c:a', 'libvorbis', '-q:a', '5', str(root / (name + '.ogg'))], check=True)
    print(name, 'WAV', (root / (name + '.wav')).stat().st_size, 'OGG', (root / (name + '.ogg')).stat().st_size)
