"""
make-ico.py  -  Muuntaa icon.png -> icon.ico (BazzBasic Manual)
Käyttö: python tools/make-ico.py
Tarvitset: pip install Pillow
"""
from PIL import Image
import os

src = os.path.join("docs", "manual", "icon.png")
dst = os.path.join("docs", "manual", "icon.ico")

if not os.path.exists(src):
    print(f"[VIRHE] Lähdetiedostoa ei löydy: {src}")
    raise SystemExit(1)

img = Image.open(src).convert("RGBA")

# ICO sisältää useita kokoja
sizes = [(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)]
img.save(dst, format="ICO", sizes=sizes)
print(f"[OK] {dst} luotu ({', '.join(str(s[0]) for s in sizes)} px)")
