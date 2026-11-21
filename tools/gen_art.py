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

# ---- cannon tower (64px, turret barrel points right) ------------------------
svg("cannon_base", '''<circle cx="32" cy="32" r="26" fill="#7a5a38"/><circle cx="32" cy="32" r="18" fill="#5a4026"/>
<circle cx="32" cy="32" r="6" fill="#3a2a18"/>''', 64, 64)
svg("cannon_turret", '''<rect x="14" y="20" width="44" height="24" rx="6" fill="#4a505c"/><rect x="50" y="17" width="12" height="30" rx="4" fill="#6a7180"/>
<circle cx="24" cy="32" r="12" fill="#3a3f4a"/><circle cx="24" cy="32" r="4" fill="#ff8a2a" stroke="none"/>''', 64, 64)

# ---- enemy walk frames (4 each), facing right; flipped in code --------------------------
def walker(name, size, body, accent, extra):
    for i in range(4):
        bob = [0, -2, 0, -2][i] * size / 44
        s1 = [-1, 0, 1, 0][i] * size * 0.12   # leg swing
        u = size / 44.0
        legs = (f'<path d="M{18*u+s1} {34*u}v{8*u}M{28*u-s1} {34*u}v{8*u}" stroke-width="{4*u}" fill="none"/>')
        svg(f"{name}_{i:02d}", f'<ellipse cx="{22*u}" cy="{size-3*u}" rx="{13*u}" ry="{3*u}" fill="#000" opacity=".25" stroke="none"/>' + legs +
            f'<g transform="translate(0 {bob})"><ellipse cx="{22*u}" cy="{26*u}" rx="{11*u}" ry="{11*u}" fill="{body}"/>'
            f'<circle cx="{25*u}" cy="{14*u}" r="{9*u}" fill="{body}"/><circle cx="{29*u}" cy="{13*u}" r="{2.5*u}" fill="#fff" stroke="none"/>'
            f'<circle cx="{30*u}" cy="{13*u}" r="{1.2*u}" fill="#000" stroke="none"/>{extra(u, accent)}</g>', size, size)

walker("archer", 44, "#4fa0a8", "#2f5f66", lambda u, a:
    f'<path d="M{16*u} {8*u}l{6*u} {-8*u}l{8*u} {8*u}z" fill="{a}"/><path d="M{36*u} {12*u}q{8*u} {10*u} 0 {22*u}" fill="none" stroke-width="{3*u}"/><path d="M{36*u} {12*u}v{22*u}" stroke-width="{1.5*u}"/>')
walker("swarm", 32, "#b04a4a", "#e8d0a0", lambda u, a:
    f'<path d="M{15*u} {8*u}l{-3*u} {-7*u}l{6*u} {4*u}zM{28*u} {8*u}l{3*u} {-7*u}l{-6*u} {4*u}z" fill="{a}"/>')
walker("boss", 96, "#8a3a4a", "#e8e0c8", lambda u, a:
    f'<path d="M{13*u} {9*u}l{-6*u} {-10*u}l{10*u} {5*u}zM{32*u} {9*u}l{6*u} {-10*u}l{-10*u} {5*u}z" fill="{a}"/>'
    f'<rect x="{34*u}" y="{20*u}" width="{4*u}" height="{22*u}" fill="#9aa0aa"/><rect x="{30*u}" y="{26*u}" width="{12*u}" height="{4*u}" fill="#6b4423"/>'
    f'<path d="M{12*u} {22*u}h{20*u}" stroke="#d9b24a" stroke-width="{3*u}"/>')

# ---- remaining towers ---------------------------------------------------------------
def tower(name, ring, inner, turret_body):
    svg(f"{name}_base", f'<circle cx="32" cy="32" r="27" fill="{ring}"/><circle cx="32" cy="32" r="19" fill="{inner}"/>'
        f'<path d="M32 5v6M32 53v6M5 32h6M53 32h6" stroke-width="5"/>', 64, 64)
    svg(f"{name}_turret", turret_body, 64, 64)

tower("gunner", "#8a8f99", "#4a78b8", '''<rect x="12" y="22" width="40" height="9" rx="3" fill="#3a3f4a"/><rect x="12" y="33" width="40" height="9" rx="3" fill="#3a3f4a"/>
<circle cx="24" cy="32" r="13" fill="#5b8fd6"/><circle cx="24" cy="32" r="5" fill="#cfe4ff" stroke-width="2"/>''')
tower("sniper", "#7a6a4a", "#4f8a4a", '''<rect x="14" y="28" width="48" height="8" rx="3" fill="#2f3a2a"/><rect x="56" y="25" width="6" height="14" rx="2" fill="#555"/>
<circle cx="24" cy="32" r="12" fill="#5fa85a"/><rect x="22" y="22" width="14" height="6" rx="2" fill="#3a3f4a"/><circle cx="24" cy="32" r="4" fill="#d8f0d0" stroke-width="2"/>''')
tower("frost", "#9ab8c8", "#5aa8d8", '''<path d="M10 32 24 18 46 32 24 46z" fill="#9ae0ff"/><path d="M46 32 62 28v8z" fill="#cfefff"/>
<path d="M24 18 32 32 24 46" fill="none" stroke-width="2.5"/><circle cx="24" cy="32" r="4" fill="#fff" stroke="none"/>''')

# ---- projectiles (point right) ---------------------------------------------------------
svg("proj_gunner", '<circle cx="12" cy="8" r="5" fill="#9fd0ff"/><path d="M2 8h4" stroke-width="3" stroke="#5b8fd6"/>', 18, 16)
svg("proj_sniper", '<path d="M2 8h22" stroke-width="3" stroke="#6b4423"/><path d="M26 8 18 4v8z" fill="#cfd4da"/><path d="M2 8 0 4M2 8 0 12" stroke-width="2" stroke="#e0e0e0"/>', 28, 16)
svg("proj_frost", '<path d="M2 8 10 2 22 8 10 14z" fill="#bfeeff"/>', 24, 16)
svg("proj_cannon", '<circle cx="10" cy="10" r="8" fill="#3a3a3f"/><circle cx="7" cy="7" r="2.5" fill="#8a8a92" stroke="none"/>', 20, 20)

# ---- remaining enemies ---------------------------------------------------------------------
walker("goblin", 44, "#6fae4a", "#3f6a2a", lambda u, a:
    f'<path d="M{14*u} {13*u}l{-8*u} {-4*u}l{6*u} {7*u}zM{33*u} {13*u}l{8*u} {-4*u}l{-6*u} {7*u}z" fill="{a}"/>'
    f'<path d="M{34*u} {24*u}l{6*u} {-10*u}" stroke="#6b4423" stroke-width="{4*u}"/>')
walker("ogre", 60, "#b8935a", "#6b4423", lambda u, a:
    f'<rect x="{16*u}" y="{20*u}" width="{14*u}" height="{4*u}" fill="{a}"/><path d="M{14*u} {30*u}h{16*u}" stroke="{a}" stroke-width="{3*u}"/>'
    f'<path d="M{38*u} {22*u}l{7*u} {-16*u}" stroke="#6b4423" stroke-width="{7*u}"/>')
for i in range(4):
    sw = [-3, 0, 3, 0][i]; bob = [0, -1.5, 0, -1.5][i]
    svg(f"wolf_{i:02d}", f'<ellipse cx="18" cy="33" rx="13" ry="3" fill="#000" opacity=".25" stroke="none"/>'
        f'<path d="M10 24v9M14 24v9M24 24v9M28 24v9" stroke-width="3.5" fill="none" transform="translate({sw} 0)"/>'
        f'<g transform="translate(0 {bob})"><ellipse cx="17" cy="19" rx="12" ry="7" fill="#8a8f99"/><path d="M5 17 0 22" stroke-width="3.5" fill="none"/>'
        f'<circle cx="29" cy="14" r="6" fill="#9a9fa9"/><path d="M33 14l6 3-6 3z" fill="#8a8f99"/><path d="M26 9l1-5 4 4z" fill="#6a6f79"/>'
        f'<circle cx="30" cy="13" r="1.4" fill="#ffd34a" stroke="none"/></g>', 40, 36)

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

svg("icon_gunner", '<circle cx="64" cy="64" r="52" fill="#3a5f9a" stroke="none"/><rect x="30" y="44" width="68" height="14" rx="5" fill="#cfd4da"/><rect x="30" y="68" width="68" height="14" rx="5" fill="#cfd4da"/><circle cx="46" cy="64" r="20" fill="#5b8fd6"/><circle cx="46" cy="64" r="8" fill="#e6f1ff" stroke-width="3"/>')
svg("icon_sniper", '<circle cx="64" cy="64" r="52" fill="#3f7a3f" stroke="none"/><rect x="22" y="56" width="88" height="14" rx="5" fill="#cfd4da"/><circle cx="46" cy="64" r="20" fill="#5fa85a"/><circle cx="46" cy="64" r="8" fill="#e0f4d8" stroke-width="3"/><path d="M96 40v48M84 64h24" stroke-width="3" fill="none"/>')
svg("icon_frost", '<circle cx="64" cy="64" r="52" fill="#3a78a8" stroke="none"/><path d="M64 22 94 64 64 106 34 64z" fill="#bfeeff"/><path d="M64 22v84M34 64h60" stroke-width="3" fill="none"/>')
