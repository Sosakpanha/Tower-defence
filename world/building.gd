## One placed building: HP, periodic income, drawing. BuildingManager/Main react to the signals.
class_name Building
extends Node2D

signal produced(amount: int, building: Building)
signal destroyed(building: Building)

const TEXTURES := {
	"farm": preload("res://assets/art/farm.svg"), "lumber": preload("res://assets/art/lumber.svg"),
	"house": preload("res://assets/art/house.svg"), "wall": preload("res://assets/art/wall.svg"),
}

var kind := "farm"
var cell := Vector2i.ZERO
var stats: Dictionary
var hp := 1.0
var max_hp := 1.0
var _timer := 0.0


func setup(k: String, c: Vector2i) -> void:
	kind = k
	cell = c
	stats = Buildings.TYPES[k]
	max_hp = stats.hp
	hp = max_hp
	position = Config.cell_center(c)
	_timer = stats.interval


func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	queue_redraw()
	if hp <= 0.0:
		destroyed.emit(self)
		queue_free()


func _process(delta: float) -> void:
	if stats.income <= 0:
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer += stats.interval
		FloatText.spawn(get_parent(), position, "+%d" % stats.income)
		produced.emit(stats.income, self)


func _draw() -> void:
	draw_texture_rect(TEXTURES[kind], Rect2(-32, -32, 64, 64), false)
	if hp < max_hp:
		draw_rect(Rect2(-24, 28, 48, 5), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-24, 28, 48 * clampf(hp / max_hp, 0, 1), 5), Color.LIME_GREEN)
