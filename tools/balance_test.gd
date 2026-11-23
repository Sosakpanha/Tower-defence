# Usage: Godot --headless --path . --fixed-fps 60 --script tools/balance_test.gd
# A simple scripted "player" follows a fixed build order, then prints gold / castle HP per wave.
# Tune Config / Buildings.TYPES / WaveManager.wave_list so this bot wins narrowly, not trivially.
extends SceneTree

const SIM_SPEED := 4.0
const IDLE_BEFORE_WAVE := 30.0  # seconds of build time the bot takes between waves

# Build order. "t:type:x,y" tower, "b:type:x,y" building, "u:x,y" upgrade tower.
const ORDER := [
	"t:gunner:8,3", "t:gunner:11,6", "b:farm:3,8", "b:lumber:4,8", "b:house:5,8", "b:farm:6,8",
	"t:gunner:8,6", "b:lumber:3,7", "t:gunner:11,3", "u:8,3", "u:11,6", "b:house:5,7",
	"b:farm:4,7", "t:sniper:9,2", "t:frost:7,4", "u:8,6", "u:11,3", "t:sniper:10,7", "t:frost:12,5",
	"b:lumber:6,7", "u:9,2", "u:10,7", "u:8,3", "u:11,6", "t:gunner:6,3", "t:gunner:13,6",
	"u:8,6", "u:11,3", "t:sniper:7,7", "t:sniper:12,2", "u:7,7", "u:12,2", "t:gunner:6,6", "t:gunner:13,3",
	"u:6,3", "u:13,6", "u:6,6", "u:13,3", "t:frost:9,7", "t:frost:10,2",
	"t:sniper:5,4", "t:sniper:14,5", "t:gunner:7,2", "t:gunner:12,7", "t:sniper:8,7", "t:sniper:11,2",
	"u:5,4", "u:14,5", "u:7,2", "u:12,7", "u:8,7", "u:11,2", "u:9,7", "u:10,2", "u:7,4", "u:12,5",
	"t:sniper:6,5", "t:sniper:13,4", "t:sniper:8,2", "t:sniper:11,7", "t:gunner:7,3", "t:gunner:12,6",
	"t:sniper:6,2", "t:sniper:13,7", "t:gunner:7,6", "t:gunner:12,3",
	"u:6,5", "u:13,4", "u:8,2", "u:11,7", "u:7,3", "u:12,6", "u:6,2", "u:13,7", "u:7,6", "u:12,3",
]

var m
var frame := 0
var step := 0
var idle := 0.0
var done := false


func _initialize() -> void:
	m = load("res://main.tscn").instantiate()
	root.add_child(m)


func _cell(s: String) -> Vector2i:
	var p := s.split(",")
	return Vector2i(int(p[0]), int(p[1]))


func _try_step() -> bool:
	var parts: PackedStringArray = ORDER[step].split(":")
	var g: int = m.gold
	match parts[0]:
		"t":
			m._select(parts[1]); m.try_place(_cell(parts[2]))
			return m.gold < g or not m.rules.can_build(_cell(parts[2]))  # skip cells that can never be built
		"b":
			m._select_building(parts[1]); m.try_place(_cell(parts[2]))
			return m.buildings.has(_cell(parts[2])) or not m.rules.can_build(_cell(parts[2])) or not m.buildings.can_afford_pop(parts[1])
		"u":
			var c := _cell(parts[1])
			if not m.towers.has(c):
				return true
			m.select_tower(c); m.upgrade_selected()
			return m.gold < g or m.towers[c].level >= 3
	return true


func _process(delta: float) -> bool:
	frame += 1
	if frame == 2:
		Engine.time_scale = SIM_SPEED
		m.waves.wave_cleared.connect(func(w: int) -> void:
			print("WAVE %2d cleared  gold=%4d castle_hp=%2d towers=%2d buildings=%2d pop=%d/%d" % [w, m.gold, m.lives, m.towers.size(), m.buildings.buildings.size(), m.buildings.pop_used(), m.buildings.pop_cap()]))
	if frame < 3 or m.game_over:
		if m.game_over and not done:
			done = true
			print("RESULT ", "LOSE at wave %d" % m.wave, " castle_hp=", m.lives, " gold=", m.gold)
		return m.game_over
	while step < ORDER.size() and _try_step():
		step += 1
	for i in mini(step, ORDER.size()):  # rebuild economy buildings that raiders destroyed
		if ORDER[i].begins_with("b:"):
			var p: PackedStringArray = ORDER[i].split(":")
			if not m.buildings.has(_cell(p[2])):
				m._select_building(p[1]); m.try_place(_cell(p[2]))
	if not m.wave_active:
		idle += delta * SIM_SPEED
		if idle >= IDLE_BEFORE_WAVE:
			idle = 0.0
			m.start_wave()
	return frame > 200000 or m.wave > 30   # endless mode: stop the bot at wave 30
