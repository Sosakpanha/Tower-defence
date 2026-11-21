## Saves/loads the kingdom to user://save.json. Saved at dawn (between waves) and when leaving.
## Pure data in/out: Main calls write()/restore(); the menu calls has_save()/read().
class_name SaveGame
extends RefCounted

const PATH := "user://save.json"
const VERSION := 1

static var pending := {}   # set by the menu ("Continue"); Main takes it on start


static func has_save() -> bool:
	return FileAccess.file_exists(PATH)


static func read() -> Dictionary:
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return {}
	var d: Variant = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary and d.get("version", 0) == VERSION else {}


static func clear() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


static func take_pending() -> Dictionary:
	var d := pending
	pending = {}
	return d


static func write(m: Node) -> void:
	var d := {"version": VERSION, "gold": m.gold, "wave": m.waves.wave, "hp": m.castle.hp, "towers": [], "buildings": []}
	for c: Vector2i in m.tower_mgr.towers:
		d.towers.append({"k": m.tower_mgr.towers[c].kind, "c": [c.x, c.y], "lv": m.tower_mgr.towers[c].level})
	for c: Vector2i in m.buildings.buildings:
		d.buildings.append({"k": m.buildings.buildings[c].kind, "c": [c.x, c.y], "hp": m.buildings.buildings[c].hp})
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


static func restore(m: Node, d: Dictionary) -> void:
	m.gold = int(d.gold)
	m.waves.wave = int(d.wave)
	m.castle.hp = int(d.hp)
	for t: Dictionary in d.towers:
		var c := Vector2i(t.c[0], t.c[1])
		m.tower_mgr.add(t.k, c)
		for i in int(t.lv) - 1:
			m.tower_mgr.towers[c].upgrade()
	for b: Dictionary in d.buildings:
		var c := Vector2i(b.c[0], b.c[1])
		m.buildings.add(b.k, c)
		m.buildings.buildings[c].hp = float(b.hp)
	m.day.resume(m.waves.wave)


## One-line description for the Continue button.
static func summary() -> String:
	var d := read()
	return "Wave %d  -  %d gold" % [d.get("wave", 0), d.get("gold", 0)] if not d.is_empty() else ""
