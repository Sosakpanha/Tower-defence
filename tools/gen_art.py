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

# Most art is AI-generated PNG (assets/art/gen, sliced by tools/slice_sheet.gd from assets/source/).
# Only the small pieces below are still drawn by code.
svg("icon_play", '''<circle cx="64" cy="64" r="52" fill="#3a8a4a"/><path d="M50 36 94 64 50 92z" fill="#fff"/>''')
svg("icon_pause", '''<circle cx="64" cy="64" r="52" fill="#b07a2a"/><rect x="40" y="36" width="16" height="56" rx="3" fill="#fff"/><rect x="72" y="36" width="16" height="56" rx="3" fill="#fff"/>''')
svg("icon_speed", '''<circle cx="64" cy="64" r="52" fill="#3a6ab0"/><path d="M32 38 62 64 32 90zM64 38 94 64 64 90z" fill="#fff"/>''')
svg("proj_gunner", '<circle cx="12" cy="8" r="5" fill="#9fd0ff"/><path d="M2 8h4" stroke-width="3" stroke="#5b8fd6"/>', 18, 16)
svg("proj_sniper", '<path d="M2 8h22" stroke-width="3" stroke="#6b4423"/><path d="M26 8 18 4v8z" fill="#cfd4da"/><path d="M2 8 0 4M2 8 0 12" stroke-width="2" stroke="#e0e0e0"/>', 28, 16)
svg("proj_frost", '<path d="M2 8 10 2 22 8 10 14z" fill="#bfeeff"/>', 24, 16)
svg("proj_cannon", '<circle cx="10" cy="10" r="8" fill="#3a3a3f"/><circle cx="7" cy="7" r="2.5" fill="#8a8a92" stroke="none"/>', 20, 20)


# ---- grass tiles (flat colour + speckles: tiles seamlessly) ------------------------------
import random
def grass(name, base, spots):
    rnd = random.Random(name)
    blades = "".join(f'<path d="M{x} {y}l-2 -5M{x} {y}l2 -5" stroke="{spots}" stroke-width="1.5" fill="none"/>' for x, y in
                     [(rnd.randint(4, 60), rnd.randint(8, 62)) for _ in range(14)])
    with open(os.path.join(OUT, name + ".svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" fill="{base}"/>{blades}</svg>')
grass("grass_a", "#5f9a46", "#7cba5a")
grass("grass_b", "#548c3e", "#6fae52")
print("ok")
