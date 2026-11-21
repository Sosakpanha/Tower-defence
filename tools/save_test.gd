# Usage: Godot --headless --path . --script tools/save_test.gd
# Builds a small kingdom, saves it, loads it into a fresh Main and compares. Prints PASS/FAIL lines.
extends SceneTree

var m
var frame := 0
var before := {}


func _initialize() -> void:
	SaveGame.clear()
	m = load("res://main.tscn").instantiate()
	root.add_child(m)


func ok(name: String, cond: bool) -> void:
	print(("PASS " if cond else "FAIL ") + name)


func _process(_d: float) -> bool:
	frame += 1
	if frame == 2:
		m.gold = 777
		m._select("cannon"); m.try_place(Vector2i(3, 3))
		m.select_tower(Vector2i(3, 3)); m.gold = 777; m.upgrade_selected()
		m._select_building("house"); m.gold = 777; m.try_place(Vector2i(6, 6))
		m.buildings.buildings[Vector2i(6, 6)].hp = 33.0
		m.waves.wave = 4; m.castle.hp = 11; m.gold = 777
		m.autosave()
		ok("save file written", SaveGame.has_save())
		ok("summary", SaveGame.summary() == "Wave 4/%d  -  777 gold" % Config.MAX_WAVE)
		m.queue_free()
	if frame == 4:
		SaveGame.pending = SaveGame.read()
		m = load("res://main.tscn").instantiate()
		root.add_child(m)
	if frame == 6:
		var t: Tower = m.towers.get(Vector2i(3, 3))
		ok("tower restored with level", t != null and t.kind == "cannon" and t.level == 2)
		ok("building restored with hp", m.buildings.has(Vector2i(6, 6)) and m.buildings.buildings[Vector2i(6, 6)].hp == 33.0)
		ok("gold/wave/hp restored", m.gold == 777 and m.wave == 4 and m.lives == 11)
		ok("back in day phase", not m.day.is_night and m.day.time_left > Config.DAY_SECONDS - 2.0)
		SaveGame.clear()
		quit()
	return false
