# Tower Defence (Godot 4.6, GDScript)

2D kingdom defence (landscape, target: Android first, then iOS). A castle in the middle,
jungle on the border where enemies spawn; enemies path to the castle (A*) around buildings.
Everything is built in code; `main.tscn` is just a Node2D with `main.gd`.
Godot binary: `/Applications/Godot.app/Contents/MacOS/Godot` (not on PATH).

## Architecture rule: code by module, keep files small

**Never put new logic in `main.gd`.** It only holds game rules and input, and wires modules
together. Each concern lives in its own file with a `class_name`, and modules talk through
**signals**, not by reaching into each other.

| Where | Owns |
|---|---|
| `core/config.gd` (`Config`) | All shared constants (grid, castle, spawn cells, start gold, castle HP, max wave, speeds). No magic numbers elsewhere. |
| `systems/pathing.gd` (`Pathing`) | A* routes to the castle; buildings are solid cells; `changed` signal makes enemies re-route; `would_block()` stops players sealing the castle in. |
| `systems/wave_manager.gd` | What each wave contains, spawn timing. Static `wave_list()` / `describe()`. |
| `systems/audio.gd` (`Sfx`) | Sound. Play with `get_tree().call_group("sfx", "play_sfx", "name", db)`. |
| `world/game_map.gd` | Terrain drawing (grass, jungle), grid <-> world conversion. |
| `core/buildings.gd` (`Buildings`) | `TYPES` table for farm/lumber/house/wall (cost, hp, income, pop_use, pop_cap). Add a building = one entry. |
| `world/building.gd` / `world/building_manager.gd` | A placed building (HP, income timer, drawing) / registry + population cap; buildings are high-cost (not solid) path cells that enemies attack through. |
| `world/float_text.gd` | `FloatText.spawn()` rising "+N" text. |
| `systems/day_cycle.gd` | Day (build countdown) -> night (wave). Signals only; Main starts the wave on `night_requested`. |
| `ui/build_menu.gd`, `ui/day_banner.gd` | Building buttons + population readout; night overlay + Day/Night banner + countdown. |
| `tools/balance_test.gd` | Headless bot: `Godot --headless --path . --fixed-fps 60 --script tools/balance_test.gd` prints gold/castle HP per wave. `tools/attack_test.gd` checks enemies chew through walls. |
| `world/castle.gd` | The castle: HP, `damaged`/`destroyed` signals, drawing. |
| `world/placement_preview.gd` | Hover highlight and range ring. |
| `ui/hud.gd` | ALL UI. Holds no game rules; shows what Main says, emits signals (`tower_chosen`, `upgrade_pressed`, ...). |
| `tower.gd`, `enemy.gd`, `projectile.gd` | Game objects. Tower types live in `Tower.TYPES` (optional `splash`, `art`, `tint`); enemy kinds in `Enemy.KINDS`. |
| `main.gd` | Rules + input + connecting signals. Target: stay under ~250 lines. |

Rules of thumb:
- New feature = new file in the right folder (new folder if none fits), connected from `main.gd`.
- A file passing ~200 lines or doing two jobs should be split.
- UI code goes in `ui/`, never in `main.gd` or game objects. Constants go in `Config`.
- Add a tower: one entry in `Tower.TYPES` (HUD button/hotkey label pick it up). Change difficulty:
  `WaveManager.wave_list()`. New map: `Config.CASTLE_RECT` / `SPAWN_CELLS` / jungle rule in `Config.is_jungle`.
- New `class_name` files: run `Godot --headless --path . --import` once, or other scripts fail with "Identifier not declared".
- macOS has no `timeout` command; run the screenshot test with `&` + `sleep`, then read the log.
- Typed GDScript. Use `var x: bool = ...` when `:=` can't infer (Variant), a common parse error.
- Other threads/tools may edit files at the same time: re-read a file right before editing it.

## Verify every change (no human needed)

1. Parse/load check, must print nothing:
   `Godot --headless --path . --quit-after 60 2>&1 | grep -E "ERROR|SCRIPT|Parse|WARN"`
2. Play + screenshot (needs a window, NOT `--headless`):
   `Godot --path . --script tools/screenshot_test.gd`, then read `shots/*.png`.
   The viewport texture lags one frame, so the harness waits a few frames before capturing.
   Expected output includes `UPGRADE level=3 spent_gold=90 ...`; extend the script when adding features.
3. In headless `--script` tests, `_ready` has not run right after `root.add_child`; wait one frame.

## Git

- `main` is always playable; use `git switch -c feature/<name>` for big work.
- Commit after each working change, with a clear message. Do not push unless asked.
- `.godot/` and `shots/` are ignored; commit `.import` files and `.uid` files.
- Remote: https://github.com/Sosakpanha/Tower-defence.git
