"""Writes the SVG art in assets/art/. Run: python3 tools/gen_art.py  (then Godot --headless --import)."""
import os
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art")
os.makedirs(OUT, exist_ok=True)
OL = "#2b1a0d"  # outline brown

def svg(name, body, w=128, h=128):
    with open(os.path.join(OUT, name + ".svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
                f'<g stroke="{OL}" stroke-width="4" stroke-linejoin="round" stroke-linecap="round">{body}</g></svg>')

def shadow(cx=64, cy=114, rx=44, ry=8):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#000" opacity=".28" stroke="none"/>'

# ---- world sprites -------------------------------------------------------
svg("farm", shadow() + '''
<rect x="12" y="30" width="104" height="80" rx="8" fill="#8a5a2b"/>
<g stroke="none"><rect x="18" y="36" width="92" height="14" fill="#e3c34a"/><rect x="18" y="54" width="92" height="14" fill="#c9a83a"/>
<rect x="18" y="72" width="92" height="14" fill="#e3c34a"/><rect x="18" y="90" width="92" height="14" fill="#c9a83a"/></g>
<g stroke-width="3" fill="none" stroke="#8c6d1c"><path d="M30 38v10M50 38v10M70 38v10M90 38v10M40 56v10M60 56v10M80 56v10M100 56v10M30 74v10M50 74v10M70 74v10M90 74v10"/></g>
<circle cx="100" cy="30" r="0"/>''')

svg("lumber", shadow() + '''
<rect x="14" y="52" width="100" height="58" rx="6" fill="#9a6a38"/>
<path d="M6 56 64 14 122 56z" fill="#6b3f22"/><path d="M26 56 64 26 102 56" fill="none" stroke="#8d5a33" stroke-width="3"/>
<rect x="52" y="76" width="24" height="34" fill="#4a2a14"/>
<g fill="#d9a35c"><circle cx="26" cy="100" r="9"/><circle cx="102" cy="100" r="9"/><circle cx="102" cy="82" r="9"/></g>
<g fill="#f0c98a" stroke-width="2"><circle cx="26" cy="100" r="4"/><circle cx="102" cy="100" r="4"/><circle cx="102" cy="82" r="4"/></g>''')

svg("house", shadow() + '''
<rect x="18" y="52" width="92" height="58" rx="4" fill="#e8d4b0"/>
<path d="M8 58 64 12 120 58z" fill="#b8453a"/><path d="M24 58 64 24 104 58" fill="none" stroke="#d6685b" stroke-width="3"/>
<rect x="54" y="74" width="22" height="36" rx="3" fill="#5a3418"/>
<rect x="26" y="68" width="18" height="18" fill="#9fd4ee"/><rect x="84" y="68" width="18" height="18" fill="#9fd4ee"/>
<rect x="88" y="22" width="12" height="22" fill="#8a8a8a"/>''')

svg("wall", shadow(rx=46) + '''
<rect x="8" y="30" width="112" height="80" rx="4" fill="#9a9a9e"/>
<path d="M8 50h112M8 70h112M8 90h112M36 30v20M72 30v20M100 50v20M30 70v20M66 70v20M92 90v20M44 90v20" fill="none" stroke-width="3" stroke="#5d5d62"/>
<path d="M8 30V18h20v12M54 30V18h20v12M100 30V18h20v12" fill="#b4b4b8"/>''')

svg("castle", shadow(rx=58, cy=122) + '''
<rect x="22" y="48" width="84" height="72" fill="#b8b4ae"/>
<path d="M22 48V36h14v8h12v-8h14v8h12v-8h14v8h12v-8h6v12z" fill="#c9c5bf"/>
<rect x="6" y="28" width="30" height="92" fill="#a8a49e"/><rect x="92" y="28" width="30" height="92" fill="#a8a49e"/>
<path d="M2 30 21 4 40 30zM88 30 107 4 126 30z" fill="#b8453a"/>
<path d="M64 48V12" stroke-width="4"/><path d="M64 12 92 20 64 30z" fill="#d93a2e"/>
<path d="M44 120V84a20 20 0 0 1 40 0v36z" fill="#4a2a14"/><path d="M64 66v54M44 94h40" stroke-width="2"/>
<rect x="15" y="52" width="8" height="14" rx="4" fill="#26303a"/><rect x="105" y="52" width="8" height="14" rx="4" fill="#26303a"/>
<rect x="60" y="54" width="8" height="12" rx="4" fill="#26303a" stroke-width="2"/>''', 128, 128)

svg("tree", '''<ellipse cx="64" cy="116" rx="30" ry="7" fill="#000" opacity=".25" stroke="none"/>
<rect x="56" y="82" width="16" height="32" fill="#6b4423"/>
<circle cx="64" cy="58" r="44" fill="#2c7a30"/><circle cx="46" cy="44" r="26" fill="#3b9a3e" stroke="none"/><circle cx="82" cy="70" r="20" fill="#236b27" stroke="none"/>''')

# ---- icons ---------------------------------------------------------------
svg("icon_cannon", '''<circle cx="64" cy="64" r="52" fill="#3a3f4a" stroke="none"/>
<g transform="rotate(-35 64 70)"><rect x="30" y="52" width="70" height="32" rx="8" fill="#5b616e"/><rect x="88" y="48" width="18" height="40" rx="5" fill="#7a808d"/></g>
<circle cx="52" cy="86" r="20" fill="#8a5a2b"/><circle cx="52" cy="86" r="7" fill="#c89a5c"/>
<circle cx="104" cy="30" r="9" fill="#ff8a2a" stroke="none"/>''')
svg("icon_farm", '''<circle cx="64" cy="64" r="52" fill="#5e8a2e" stroke="none"/>
<path d="M64 108V40" stroke-width="5"/><g fill="#e8c640"><ellipse cx="50" cy="46" rx="9" ry="16" transform="rotate(-25 50 46)"/><ellipse cx="78" cy="46" rx="9" ry="16" transform="rotate(25 78 46)"/>
<ellipse cx="50" cy="72" rx="9" ry="16" transform="rotate(-25 50 72)"/><ellipse cx="78" cy="72" rx="9" ry="16" transform="rotate(25 78 72)"/><ellipse cx="64" cy="26" rx="9" ry="16"/></g>''')
svg("icon_lumber", '''<circle cx="64" cy="64" r="52" fill="#6b4a2a" stroke="none"/>
<rect x="56" y="30" width="16" height="74" rx="4" fill="#a0713c" transform="rotate(35 64 64)"/>
<path d="M30 40 70 36 82 62 40 70z" fill="#c8ccd2" transform="rotate(-20 56 52)"/>''')
svg("icon_house", '''<circle cx="64" cy="64" r="52" fill="#4a6fa5" stroke="none"/>
<rect x="30" y="62" width="68" height="40" fill="#e8d4b0"/><path d="M20 66 64 26 108 66z" fill="#b8453a"/><rect x="54" y="78" width="20" height="24" fill="#5a3418"/>''')
svg("icon_wall", '''<circle cx="64" cy="64" r="52" fill="#6b6b72" stroke="none"/>
<rect x="24" y="40" width="80" height="54" fill="#a8a8ae"/><path d="M24 40V28h16v12M56 40V28h16v12M88 40V28h16v12" fill="#c4c4ca"/>
<path d="M24 58h80M24 76h80M50 40v18M78 58v18M44 76v18" fill="none" stroke-width="3"/>''')
svg("icon_play", '''<circle cx="64" cy="64" r="52" fill="#3a8a4a"/><path d="M50 36 94 64 50 92z" fill="#fff"/>''')
svg("icon_pause", '''<circle cx="64" cy="64" r="52" fill="#b07a2a"/><rect x="40" y="36" width="16" height="56" rx="3" fill="#fff"/><rect x="72" y="36" width="16" height="56" rx="3" fill="#fff"/>''')
svg("icon_speed", '''<circle cx="64" cy="64" r="52" fill="#3a6ab0"/><path d="M32 38 62 64 32 90zM64 38 94 64 64 90z" fill="#fff"/>''')
svg("icon_horn", '''<circle cx="64" cy="64" r="52" fill="#a8342a"/><path d="M30 56 84 30 98 90 30 76z" fill="#f2d27a"/><path d="M98 44l14-8M100 62h16M98 80l14 8" fill="none" stroke-width="4"/>''')
print("ok")
