# Usage: Godot --path . --script tools/screenshot_test.gd   (needs a window, NOT --headless)
# Drives the game through a scripted scenario and saves PNGs to res://shots/.
extends SceneTree

var m
var frame := 0
var wait := 0
var sim_time := 0.0
var step := 0

func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	m = load("res://main.tscn").instantiate()
	root.add_child(m)

func shot(name: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png("res://shots/%s.png" % name)
	print("SHOT ", name)

func _process(delta: float) -> bool:
	frame += 1
	if frame < 5:
		return false
	if wait > 0:        # let the renderer catch up before capturing
		wait -= 1
		return false
	match step:
		0:
			m.gold = 600
			var kinds := ["gunner", "sniper", "frost", "gunner", "sniper"]
			var cells := [Vector2i(3, 1), Vector2i(5, 3), Vector2i(2, 3), Vector2i(8, 6), Vector2i(10, 3)]
			for i in cells.size():
				m._select(kinds[i]); m.try_place(cells[i])
			m._select("gunner")
			print("PREVIEW ", m.hud.preview_label.text)
			m.select_tower(Vector2i(3, 1))
			var g: int = m.gold
			m.upgrade_selected(); m.upgrade_selected(); m.upgrade_selected()  # 3rd refused: max level
			print("UPGRADE level=", m.towers[Vector2i(3, 1)].level, " spent_gold=", g - m.gold, " btn=", m.hud.upgrade_btn.text, " sell=", m.hud.sell_btn.text)
			m.cycle_speed()
			print("SPEED ", Engine.time_scale, " ", m.hud.speed_button.text)
			wait = 4; step = 1
		1:
			shot("01_upgrade_panel")
			m.cycle_speed(); m.cycle_speed()
			m.deselect_tower()
			m.start_wave()
			print("PREVIEW(active) ", m.hud.preview_label.text)
			step = 2
		2:
			sim_time += delta
			if sim_time > 6.0:
				wait = 3; step = 3
		3:
			shot("02_wave_in_progress")
			print("STATE gold=", m.gold, " lives=", m.lives, " enemies=", m.enemies_node.get_child_count())
			return true
	return false
