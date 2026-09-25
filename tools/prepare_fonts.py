"""Pin readable weights for identical rendering on desktop and Android."""
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

root = Path(__file__).resolve().parents[1] / 'assets/fonts'
for family, weight in [('manrope', 450), ('cormorantgaramond', 500)]:
    font = TTFont(root / f'{family}.ttf')
    instantiateVariableFont(font, {'wght': weight}, inplace=True)
    font.save(root / f'{family}-readable.ttf')
