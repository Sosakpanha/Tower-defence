## Decides what each wave contains, spawns it over time, and reports what happens.
class_name WaveManager
extends Node

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_killed(enemy: Enemy)
signal enemy_leaked(enemy: Enemy)

var wave := 0
var active := false
var queue: Array[String] = []
var timer := 0.0
var path_points: Array[Vector2] = []
var enemies_node: Node2D


func setup(path: Array[Vector2], enemies_parent: Node2D) -> void:
	path_points = path
	enemies_node = enemies_parent


## Enemy kinds for wave `w`, in spawn order. Edit this to change the difficulty curve.
static func wave_list(w: int) -> Array[String]:
	var list: Array[String] = []
	for i in 5 + w * 2:
		var kind := "normal"
		if w >= 3 and i % 4 == 3:
			kind = "fast"
		if w >= 5 and i % 5 == 4:
			kind = "tank"
		list.append(kind)
	if w % 5 == 0:
		list.append("tank")
		list.append("tank")
	return list


static func describe(w: int) -> String:
	var counts := {}
	for k in wave_list(w):
		counts[k] = counts.get(k, 0) + 1
	var parts: Array[String] = []
	for k in ["normal", "fast", "tank"]:
		if counts.has(k):
			parts.append("%d %s" % [counts[k], Config.KIND_NAMES[k]])
	return ", ".join(parts)


func start() -> bool:
	if active:
		return false
	wave += 1
	active = true
	queue = wave_list(wave)
	timer = 0.0
	wave_started.emit(wave)
	return true


func _process(delta: float) -> void:
	if not active:
		return
	if not queue.is_empty():
		timer -= delta
		if timer <= 0.0:
			timer = maxf(0.4, 1.0 - wave * 0.05)
			_spawn(queue.pop_front())
	elif enemies_node.get_child_count() == 0:
		active = false
		wave_cleared.emit(wave)


func _spawn(kind: String) -> void:
	var e := Enemy.new()
	e.setup(path_points, kind, wave)
	e.died.connect(func(en: Enemy) -> void: enemy_killed.emit(en))
	e.reached_end.connect(func(en: Enemy) -> void: enemy_leaked.emit(en))
	enemies_node.add_child(e)
