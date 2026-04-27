"""
make-chm.py  –  Generoi HTML Help Workshop -projekti BazzBasic-manuaalille
Käyttö: python tools/make-chm.py dist/chm

Tarvitset: HTML Help Workshop asennettuna
  choco install html-help-workshop   TAI
  https://www.microsoft.com/en-us/download/details.aspx?id=21138
"""

import sys
import os

# Sivujen järjestys ja otsikot (sama kuin _sidebar.md)
PAGES = [
    ("README.html",                  "Home"),
    ("contact.html",                 "Contact & License"),
    ("installation.html",            "Installation"),
    ("ide-usage.html",               "IDE Usage"),
    ("packaging.html",               "Creating EXE"),
    ("libraries.html",               "Creating Libraries"),
    ("cli_features.html",            "More CLI Features"),
    ("ai-assist.html",               "AI Assisted Help"),
    ("rosetta-code.html",            "Rosetta Code"),
    ("beginners-guide.html",         "Beginner's Guide"),
    ("variables-and-constants.html", "Variables & Constants"),
    ("arrays_and_json.html",         "Arrays & JSON"),
    ("operators.html",               "Operators"),
    ("comments.html",                "Comments"),
    ("user-defined-functions.html",  "User-defined Functions"),
    ("control-flow.html",            "Control Flow"),
    ("statements.html",              "Statements A-Z"),
    ("functions.html",               "Functions"),
    ("math_functions.html",          "  Math Functions"),
    ("string_functions.html",        "  String Functions"),
    ("input_functions.html",         "  Input Functions"),
    ("fast_trigonomy.html",          "  Fast Trigonometry"),
    ("other_functions.html",         "  Other Functions"),
    ("file-io.html",                 "File I/O"),
    ("graphics.html",                "Graphics Commands"),
    ("sounds.html",                  "Sound Commands"),
    ("network.html",                 "Network"),
    ("preprocessor.html",            "Preprocessor & Source Control"),
    ("keywords.html",                "Reserved Words"),
]

def write_hhp(chm_dir):
    """HTML Help Project -tiedosto"""
    files = "\n".join(f[0] for f in PAGES)
    content = f"""[OPTIONS]
Compiled file=BazzBasic.chm
Contents file=BazzBasic.hhc
Index file=BazzBasic.hhk
Default topic=README.html
Title=BazzBasic Manual
Language=0x409 English (United States)
Full-text search=Yes
Default Font=Segoe UI,10,0

[FILES]
{files}
"""
    path = os.path.join(chm_dir, "BazzBasic.hhp")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OK] {path}")


def write_hhc(chm_dir):
    """HTML Help Contents -tiedosto (sisällysluettelo)"""
    items = ""
    for filename, title in PAGES:
        indent = "      " if title.startswith("  ") else "   "
        clean_title = title.strip()
        items += f"""{indent}<LI><OBJECT type="text/sitemap">
{indent}   <param name="Name" value="{clean_title}">
{indent}   <param name="Local" value="{filename}">
{indent}</OBJECT></LI>\n"""

    content = f"""<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="make-chm.py">
</HEAD>
<BODY>
<OBJECT type="text/site properties">
   <param name="Window Styles" value="0x800025">
   <param name="ImageType" value="Folder">
</OBJECT>
<UL>
{items}</UL>
</BODY>
</HTML>
"""
    path = os.path.join(chm_dir, "BazzBasic.hhc")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OK] {path}")


def write_hhk(chm_dir):
    """HTML Help Index -tiedosto (hakemisto, yksinkertainen versio)"""
    items = ""
    for filename, title in PAGES:
        clean_title = title.strip()
        items += f"""   <LI><OBJECT type="text/sitemap">
      <param name="Name" value="{clean_title}">
      <param name="Local" value="{filename}">
   </OBJECT></LI>\n"""

    content = f"""<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="make-chm.py">
</HEAD>
<BODY>
<UL>
{items}</UL>
</BODY>
</HTML>
"""
    path = os.path.join(chm_dir, "BazzBasic.hhk")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OK] {path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kaytto: python tools/make-chm.py <chm-hakemisto>")
        sys.exit(1)

    chm_dir = sys.argv[1]

    if not os.path.isdir(chm_dir):
        print(f"[VIRHE] Hakemistoa ei loydy: {chm_dir}")
        sys.exit(1)

    print(f"\nGeneroidaan CHM-projektitiedostot: {chm_dir}")
    write_hhp(chm_dir)
    write_hhc(chm_dir)
    write_hhk(chm_dir)
    print("\nValmis. Seuraavaksi aja:")
    print(f'  "C:\\Program Files (x86)\\HTML Help Workshop\\hhc.exe" {chm_dir}\\BazzBasic.hhp')
