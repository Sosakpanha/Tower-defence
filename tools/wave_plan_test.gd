# Usage: Godot --headless --path . --fixed-fps 60 --script tools/wave_plan_test.gd
# Checks WavePlan is deterministic and that real spawning follows the plan (portals + kinds),
# and that abilities respect cooldowns. Prints PASS/FAIL lines; "ALL OK" at the end.
extends SceneTree

var fails := 0
var m
var frame := 0
var phase := 0
var seen := {}
var spawn_cells: Array[Vector2i] = []
var spawn_kinds: Array[String] = []


func check(ok: bool, what: String) -> void:
	print(("PASS " if ok else "FAIL ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	# 1. determinism + shape
	var bosses_ok := true
	var det := true
	var sizes := {}
	for w in range(1, 31):
		var a := WavePlan.portals(w)
		var b := WavePlan.portals(w)
		det = det and a == b and WavePlan.kinds(w) == WavePlan.kinds(w)
		var uniq := {}
		for c in a:
			uniq[c] = true
			det = det and Config.SPAWN_CELLS.has(c)
		det = det and uniq.size() == a.size() and a.size() >= 1
		sizes[w] = a.size()
		if WavePlan.is_boss(w):
			bosses_ok = bosses_ok and a.size() >= 2 and WavePlan.kinds(w)[0] == "boss" \
				and WavePlan.kinds(w).size() > WaveManager.wave_list(w).size() \
				and WavePlan.clear_bonus(w) > 0
		else:
			bosses_ok = bosses_ok and WavePlan.clear_bonus(w) == 0 and not WavePlan.kinds(w).has("boss")
	check(det, "portals/kinds deterministic, unique, valid cells (waves 1-30)")
	check(bosses_ok, "boss waves: >=2 portals, boss first, escort added, bonus; others none")
	check(sizes[1] == 1 and sizes[2] == 1, "waves 1-2 use a single portal")
	check(sizes[25] > sizes[1], "late waves use more portals (w25=%d)" % sizes[25])
	print("PORTALS ", sizes)
	# 2. live spawning follows the plan
	m = load("res://main.tscn").instantiate()
	root.add_child(m)


func _process(_delta: float) -> bool:
	frame += 1
	if frame < 3:
		return false
	match phase:
		0:
			Engine.time_scale = 8.0
			m.castle.hp = 1000000
			m.day.enabled = false
			m.waves.wave = 9   # next wave = 10, the first boss wave (with escorts)
			m.waves.start()
			phase = 1
		1:
			for e in m.enemies_node.get_children():
				if not e is Enemy:
					continue
				if not seen.has(e):
					seen[e] = true
					spawn_cells.append(Config.world_to_cell(e.position))
					spawn_kinds.append(e.kind)
			if not m.waves.queue.is_empty():
				return false
			var n := WavePlan.kinds(10).size()
			var ok_cells := spawn_cells.size() == n
			for i in mini(n, spawn_cells.size()):
				ok_cells = ok_cells and spawn_cells[i] == WavePlan.spawn_cell(10, i)
			check(ok_cells, "live wave 10: every enemy spawned at its planned portal (%d enemies)" % n)
			check(spawn_kinds == WavePlan.kinds(10), "live wave 10: kinds/order match the plan")
			phase = 2
		2:
			var ab: Abilities = m.abilities
			var hp0 := 0.0
			for e in m.enemies_node.get_children():
				if e is Enemy:
					hp0 += e.hp
			check(ab.is_ready("freeze"), "freeze ready")
			ab.press("freeze")
			check(not ab.is_ready("freeze"), "freeze on cooldown after use")
			var slowed := 0
			for e in m.enemies_node.get_children():
				if e.slow_timer > 0.0:
					slowed += 1
			check(slowed > 0, "freeze slows enemies (%d)" % slowed)
			ab.press("volley")
			check(ab.aiming == "volley", "volley armed by press")
			var target: Vector2 = m.enemies_node.get_child(0).position
			ab.aim_tap(target)
			var hp1 := 0.0
			for e in m.enemies_node.get_children():
				hp1 += e.hp
			check(hp1 < hp0 and ab.aiming == "" and not ab.is_ready("volley"), "volley damages enemies, disarms, starts cooldown")
			ab.cd["volley"] = 0.0
			ab.press("volley"); ab.press("volley")
			check(ab.aiming == "", "pressing armed ability again cancels aim")
			print("ALL OK" if fails == 0 else "FAILURES %d" % fails)
			quit(fails)
			return true
	return false
