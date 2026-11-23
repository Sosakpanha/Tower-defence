# Usage: Godot --headless --path . --script tools/evolution_test.gd
# Every tower kind x branch: level to max, evolve, check cost/stats/rules, save and restore.
extends SceneTree

var m
var frame := 0
var fails := 0


func _initialize() -> void:
	SaveGame.clear()
	m = load("res://main.tscn").instantiate()
	root.add_child(m)


func ok(name: String, cond: bool) -> void:
	print(("PASS " if cond else "FAIL ") + name)
	if not cond:
		fails += 1


func _process(_d: float) -> bool:
	frame += 1
	if frame == 2:
		var x := 2
		for kind: String in Evolutions.BRANCHES:
			for id: String in Evolutions.branches(kind):
				var c := Vector2i(x, 1 + (x % 2) * 7)
				x += 1
				m.gold = 5000
				m._select(kind); m.try_place(c)
				m.select_tower(c)
				var t: Tower = m.towers[c]
				m.evolve_selected(id)
				ok("%s/%s refused below max level" % [kind, id], t.evo == "")
				m.upgrade_selected(); m.upgrade_selected()
				var dmg := t.get_damage()
				var rng := t.get_range()
				var rate := t.get_rate()
				var g: int = m.gold
				ok("%s/%s evolve button shown" % [kind, id], m.hud.evolve_box.visible and not m.hud.upgrade_btn.visible)
				m.evolve_selected(id)
				ok("%s/%s evolved, paid %d" % [kind, id, Evolutions.cost(kind)], t.evo == id and g - m.gold == Evolutions.cost(kind))
				ok("%s/%s stats changed" % [kind, id], t.get_damage() != dmg or t.get_range() != rng or t.get_rate() != rate)
				var other := ""
				for o: String in Evolutions.branches(kind):
					if o != id:
						other = o
				m.evolve_selected(other)
				ok("%s second evolve refused" % kind, t.evo == id and not m.hud.evolve_box.visible)
		m.autosave()
		ok("save written", SaveGame.has_save())
		m.queue_free()
	if frame == 4:
		SaveGame.pending = SaveGame.read()
		m = load("res://main.tscn").instantiate()
		root.add_child(m)
	if frame == 6:
		var n := 0
		for t: Tower in m.towers.values():
			n += 1
			ok("restored %s evo=%s" % [t.kind, t.evo], t.evo != "" and t.level == 3 and Evolutions.has(t.kind, t.evo))
		ok("all 8 towers restored", n == 8)
		SaveGame.clear()
		print("FAILS ", fails)
		quit()
	return false
