# Asset Prompts (ChatGPT image generation)

Style: flat vector cartoon, medieval fantasy, top-down 2D. Grid: 64x64 tiles, map 20x10.

## How to use
1. Do **Step 0** first, in ONE chat. Keep using that same chat for everything else so the style stays consistent.
2. Paste the **STYLE BLOCK** at the start of every prompt (or just say "same style as before" within the same chat).
3. Save each result to the path shown. Name files exactly as listed.
4. Generate at the largest size, then we downscale with a script (generate big, shrink small = cleaner).
5. Ask for a **solid flat magenta (#FF00FF) background** for sprites. It is easy to remove cleanly. ChatGPT's "transparent background" often leaves halos.

## STYLE BLOCK (paste into every prompt)
```
Flat vector cartoon game asset, medieval fantasy, strict top-down view (camera looking straight down), clean bold dark-brown outlines (consistent ~3px weight), simple cel shading with one soft highlight and one shadow tone, limited saturated palette, no gradients, no textures, no text, no watermark, no drop shadow, centered, solid flat magenta #FF00FF background.
```

---

## Step 0: Style reference (do this first, save to assets/_reference/)
```
[STYLE BLOCK]
Create a style reference sheet for a medieval fantasy tower defence game, 3 items in a row with even spacing: (1) a round stone archer tower seen from above, (2) a green goblin enemy seen from above, (3) a 64x64 grass tile and a dirt path tile side by side. All must share the exact same outline weight, palette and shading.
```
Review it together. Tell me what to tweak, then lock it.

---

## Towers (save to assets/towers/)
Each tower = a **base** (static) + a **turret** (rotates). Turret must point **RIGHT** (east). Turret pivot = image centre.

Matches `Tower.TYPES` in tower.gd: gunner (blue), sniper (green), frost (light blue).

### gunner_base.png
```
[STYLE BLOCK]
Top-down round stone tower base for a rapid-fire crossbow tower, blue banner accents, no weapon on it (empty circular mounting platform in the centre). Square canvas, 1:1.
```
### gunner_turret.png
```
[STYLE BLOCK]
Top-down double crossbow weapon, blue accents, pointing exactly to the RIGHT (east), centred on the canvas so the pivot is in the middle, no base. Square canvas, 1:1.
```
### sniper_base.png
```
[STYLE BLOCK]
Top-down round stone watchtower base, green banner accents, empty circular mounting platform in the centre, no weapon. Square canvas, 1:1.
```
### sniper_turret.png
```
[STYLE BLOCK]
Top-down long heavy ballista / long-barrel siege bow, green accents, pointing exactly to the RIGHT (east), centred so the pivot is in the middle, no base. Square canvas, 1:1.
```
### frost_base.png
```
[STYLE BLOCK]
Top-down round icy stone tower base with frost crystals around the edge, light blue accents, empty circular mounting platform in the centre, no weapon. Square canvas, 1:1.
```
### frost_turret.png
```
[STYLE BLOCK]
Top-down magic staff topped with a glowing ice crystal, light blue accents, pointing exactly to the RIGHT (east), centred so the pivot is in the middle, no base. Square canvas, 1:1.
```

---

## Enemies (save to assets/enemies/)
All face **RIGHT**. Ask for a **sprite sheet of 4 walk-cycle frames in a row**, equal spacing, same size per frame.

Sizes in game: normal ~24px, fast ~18px, tank ~32px.

### goblin_walk.png (normal, red-ish)
```
[STYLE BLOCK]
Sprite sheet, 4 frames in one horizontal row, walk cycle of a small green goblin warrior with a red tunic, top-down view, facing RIGHT (east). Equal frame size, equal spacing, character centred in each frame.
```
### wolf_walk.png (fast, gold)
```
[STYLE BLOCK]
Sprite sheet, 4 frames in one horizontal row, run cycle of a small fast golden-furred wolf, top-down view, facing RIGHT (east). Smaller than the goblin. Equal frame size, equal spacing, centred in each frame.
```
### ogre_walk.png (tank, purple)
```
[STYLE BLOCK]
Sprite sheet, 4 frames in one horizontal row, slow heavy walk cycle of a big purple ogre with a wooden club, top-down view, facing RIGHT (east). Larger than the goblin. Equal frame size, equal spacing, centred in each frame.
```

---

## Projectiles (save to assets/projectiles/)
Pointing RIGHT, one small item each. Generate all three on one sheet, then we slice.

### projectiles_sheet.png
```
[STYLE BLOCK]
Three tiny projectiles in a row, each pointing RIGHT (east): (1) a blue-fletched crossbow bolt, (2) a long green heavy arrow, (3) a light-blue ice shard with a small frost trail. Wide spacing between them.
```

---

## Map tiles (save to assets/tiles/)
Must be **seamless** and flat, no outlines on the tile edges (outlines only inside). Square, 1:1.

### grass_a.png / grass_b.png
```
[STYLE BLOCK, but fill the entire canvas, no magenta background]
Seamless tileable top-down grass tile, soft green, a few tiny tufts and tiny flowers, no outline on the tile edges. Variant A. (Then ask for "variant B: slightly darker, different tufts".)
```
### path_straight.png
```
[STYLE BLOCK, but fill the entire canvas, no magenta background]
Seamless tileable top-down dirt road tile, horizontal straight path of packed brown dirt with small pebbles, grass edges on the top and bottom, left and right edges continue seamlessly.
```
### path_corner.png
```
[STYLE BLOCK, but fill the entire canvas, no magenta background]
Top-down dirt road corner tile, path enters from the left and exits at the bottom, brown packed dirt with pebbles, grass in the outer corners.
```
(I can rotate the straight and corner pieces in code, so we only need one of each.)

### buildable_marker.png (optional)
```
[STYLE BLOCK]
Top-down square stone build-pad plate, subtle, slightly lighter than grass, simple rounded-square outline.
```

---

## UI (save to assets/ui/)
Icons on magenta background, then we cut them out.

### icons_sheet.png
```
[STYLE BLOCK]
Icon sheet, 3x2 grid, wide spacing: gold coin, red heart, wave flag/horn, a blue crossbow icon, a green ballista icon, a light-blue ice crystal icon. Front view (not top-down), each fits a square.
```
### panel_and_button.png
```
[STYLE BLOCK]
UI kit: one wooden-framed parchment panel (rounded rectangle) and one wooden button in normal state and one in pressed state, front view, no text.
```

---

## Audio (not from ChatGPT)
| File | Source | Notes |
|---|---|---|
| sfx/shoot_gunner.wav | jsfxr "Laser/Shoot" preset | short, light |
| sfx/shoot_sniper.wav | jsfxr | deeper, louder |
| sfx/shoot_frost.wav | jsfxr | high, glassy |
| sfx/hit.wav | jsfxr "Hit/Hurt" | |
| sfx/enemy_die.wav | jsfxr "Explosion" (small) | |
| sfx/place.wav, sell.wav | jsfxr "Pickup/Coin" | |
| sfx/wave_start.wav | jsfxr or Kenney | horn-like |
| sfx/win.wav, lose.wav | Kenney / jsfxr | |
| music/theme.ogg | Pixabay / Kenney / incompetech | loopable, medieval |

---

## Checklist
- [ ] Step 0 reference approved
- [ ] 3 tower bases + 3 turrets
- [ ] 3 enemy walk sheets
- [ ] projectiles sheet
- [ ] grass x2, path straight, path corner
- [ ] UI icons + panel/button
- [ ] SFX + music
