# Usage: Godot --path . --script tools/touch_test.gd   (needs a window, NOT --headless)
# Sends real InputEventScreenTouch events (emulated to mouse like on a phone) and checks
# tap-to-preview, tap-to-build, tap-tower-to-select, tap-button-to-upgrade, tap-ground, pause, restart.
extends SceneTree

var m
var frame := 0
var step := 0
var wait := 0

func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	m = load("res://main.tscn").instantiate()
	root.add_child(m)

func tap(p: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventScreenTouch.new()
		e.index = 0
		e.position = p
		e.pressed = pressed
		Input.parse_input_event(e)

func shot(name: String) -> void:
	root.get_texture().get_image().save_png("res://shots/%s.png" % name)
	print("SHOT ", name)

func ok(label: String, cond: bool) -> void:
	print(("PASS " if cond else "FAIL "), label)

func _process(_d: float) -> bool:
	frame += 1
	if frame < 5:
		return false
	if wait > 0:
		wait -= 1
		return false
	var c := Vector2i(3, 1)
	match step:
		0:
			m.gold = 500
			tap(Config.cell_center(c)); wait = 2; step = 1
		1:
			ok("first tap only previews (no tower, no gold spent)", m.towers.is_empty() and m.gold == 500 and m.preview.pending == c)
			shot("touch_01_preview")
			tap(Config.cell_center(c)); wait = 2; step = 2
		2:
			ok("second tap builds", m.towers.has(c) and m.gold == 500 - Tower.TYPES["gunner"].cost)
			tap(Vector2(Config.cell_center(c))); wait = 2; step = 3
		3:
			ok("tap tower opens upgrade panel", m.sel_cell == c and m.hud.tower_panel.visible)
			var b: Button = m.hud.upgrade_btn
			var g: int = m.gold
			tap(b.get_global_rect().get_center()); wait = 2; step = 4
			set_meta("g", g)
		4:
			ok("tap Upgrade button upgrades", m.towers[c].level == 2 and m.gold < get_meta("g"))
			shot("touch_02_upgrade_panel")
			tap(Config.cell_center(Vector2i(10, 0))); wait = 2; step = 5   # free cell: preview + deselect? panel stays until build
		5:
			tap(Vector2(1100, 78)); wait = 2; step = 6   # empty strip of the top bar, right of the buttons
		6:
			ok("tap outside grid deselects", m.sel_cell == Vector2i(-1, -1) and not m.hud.tower_panel.visible)
			tap(m.hud.pause_button.get_global_rect().get_center()); wait = 2; step = 7
		7:
			ok("pause button pauses", paused and m.hud.overlay.visible)
			shot("touch_03_paused")
			tap(m.hud.overlay.resume_btn.get_global_rect().get_center()); wait = 2; step = 8
		8:
			ok("resume works", not paused and not m.hud.overlay.visible)
			m.lifecycle.backgrounded.emit(); wait = 2; step = 9
		9:
			ok("backgrounding pauses", paused)
			m.set_paused(false)
			m._end_game(); wait = 3; step = 10
		10:
			shot("touch_04_gameover")
			ok("game over shows restart", m.hud.overlay.visible and m.hud.overlay.restart_btn.visible)
			tap(m.hud.overlay.restart_btn.get_global_rect().get_center()); wait = 4; step = 11
		11:
			print("NOTE restart() ran (scene reload itself needs a current_scene, absent in --script)")
			return true
	return false
