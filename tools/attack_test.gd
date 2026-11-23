# Usage: Godot --headless --path . --script tools/attack_test.gd
# Walls the castle in completely, spawns raiders, checks they chew through the wall.
extends SceneTree

var m
var frame := 0
var spawned := false
var start_walls := 0

func _initialize() -> void:
	m = load("res://main.tscn").instantiate()
	root.add_child(m)

func _process(delta: float) -> bool:
	frame += 1
	if frame == 2:
		for x in range(8, 12):
			for y in range(3, 7):
				var c := Vector2i(x, y)
				if not Config.is_castle(c):
					m.buildings.add("wall", c)
		start_walls = m.buildings.buildings.size()
		print("WALLS ", m.buildings.buildings.size(), " route_len=", m.pathing.route(Vector2i(0, 2)).size())
		m.waves.setup(m.pathing, m.enemies_node)
		m.waves.queue.assign(["normal", "normal"])
		m.waves.active = true
		m.waves.wave = 1
	if frame > 2:
		Engine.time_scale = 1.0
	if frame % 600 == 0 or frame > 4000:
		var total := 0.0
		for b in m.buildings.buildings.values():
			total += b.hp
		print("frame ", frame, " wall_hp_total=", total, " walls=", m.buildings.buildings.size(), " castle=", m.lives, " enemies=", m.enemies_node.get_child_count())
	if frame > 4000:
		# Enemies must chew through the blocking wall(s) (fewer walls left), then reach the castle.
		# Remaining walls stay at full HP once a gap opens, so total wall HP is not the signal.
		var ok: bool = m.buildings.buildings.size() < start_walls and m.lives < Config.CASTLE_HP
		print("ATTACK_TEST ", "PASS" if ok else "FAIL")
		return true
	return false
