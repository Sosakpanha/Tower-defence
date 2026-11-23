## Decides what each wave contains, spawns it over time, and reports what happens.
class_name WaveManager
extends Node

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_killed(enemy: Enemy)
signal castle_hit(damage: int)   # an enemy at the castle landed a hit
signal boss_spawned

var wave := 0
var active := false
var queue: Array[String] = []
var spawned := 0   # enemies spawned so far this wave (picks the portal via WavePlan)
var timer := 0.0
var pathing: Pathing
var enemies_node: Node2D


func setup(path: Pathing, enemies_parent: Node2D) -> void:
	pathing = path
	enemies_node = enemies_parent


## Enemy kinds for wave `w`, in spawn order. Edit this to change the difficulty curve.
static func wave_list(w: int) -> Array[String]:
	var list: Array[String] = []
	for i in Config.WAVE_COUNT_BASE + int(w * Config.WAVE_COUNT_LIN + w * w * Config.WAVE_COUNT_QUAD):
		var kind := "normal"
		if w >= 3 and i % 4 == 3:
			kind = "fast"
		if w >= 4 and i % 3 == 2:
			kind = "archer"
		if w >= 5 and i % 5 == 4:
			kind = "tank"
		list.append(kind)
	if w >= 2 and w % 3 == 2:  # rat swarm
		for i in 4 + w:
			list.append("swarm")
	if w == 5:  # first milestone: a pair of ogres
		list.append_array(["tank", "tank"])
	elif WavePlan.is_boss(w):
		for i in 1 + w / 20:
			list.append("boss")
	return list


static func describe(w: int) -> String:
	var counts := WavePlan.counts(w)
	var parts: Array[String] = []
	for k in Config.KIND_NAMES:
		if counts.has(k):
			parts.append("%d %s" % [counts[k], Config.KIND_NAMES[k]])
	return ", ".join(parts)


func start() -> bool:
	if active:
		return false
	wave += 1
	active = true
	queue = WavePlan.kinds(wave)
	spawned = 0
	timer = 0.0
	wave_started.emit(wave)
	return true


func _process(delta: float) -> void:
	if not active:
		return
	if not queue.is_empty():
		timer -= delta
		if timer <= 0.0:
			timer = maxf(0.25, 1.0 - wave * 0.04)
			_spawn(queue.pop_front())
	elif enemies_node.get_child_count() == 0:
		active = false
		wave_cleared.emit(wave)


func _spawn(kind: String) -> void:
	var e := Enemy.new()
	e.setup(pathing, WavePlan.spawn_cell(wave, spawned), kind, wave)
	spawned += 1
	if kind == "boss":
		boss_spawned.emit()
	e.died.connect(func(en: Enemy) -> void: enemy_killed.emit(en))
	e.hit_castle.connect(func(d: int) -> void: castle_hit.emit(d))
	enemies_node.add_child(e)
