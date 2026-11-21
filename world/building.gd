## One placed building: HP, periodic income, drawing. BuildingManager/Main react to the signals.
class_name Building
extends Node2D

signal produced(amount: int, building: Building)
signal destroyed(building: Building)

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
	var col: Color = stats.color
	var dark := col.darkened(0.45)
	match kind:
		"farm":
			draw_rect(Rect2(-26, -20, 52, 40), col)
			for i in 4:
				draw_line(Vector2(-26, -12 + i * 9), Vector2(26, -12 + i * 9), Color(0.45, 0.6, 0.15), 3.0)
			draw_rect(Rect2(-26, -20, 52, 40), dark, false, 2.0)
		"lumber":
			draw_rect(Rect2(-24, -4, 48, 26), col)
			draw_rect(Rect2(-24, -4, 48, 26), dark, false, 2.0)
			draw_colored_polygon(PackedVector2Array([Vector2(-28, -4), Vector2(0, -26), Vector2(28, -4)]), Color(0.3, 0.2, 0.1))
			for i in 3:
				draw_circle(Vector2(-14 + i * 14, 12), 5.0, Color(0.7, 0.5, 0.25))
		"house":
			draw_rect(Rect2(-22, -6, 44, 28), col)
			draw_rect(Rect2(-22, -6, 44, 28), dark, false, 2.0)
			draw_colored_polygon(PackedVector2Array([Vector2(-27, -6), Vector2(0, -28), Vector2(27, -6)]), Color(0.35, 0.2, 0.15))
			draw_rect(Rect2(-5, 6, 10, 16), Color(0.25, 0.14, 0.08))
		_:
			draw_rect(Rect2(-28, -28, 56, 56), col)
			for y in [-14, 0, 14]:
				draw_line(Vector2(-28, y), Vector2(28, y), dark, 2.0)
			draw_rect(Rect2(-28, -28, 56, 56), dark, false, 3.0)
	if hp < max_hp:
		draw_rect(Rect2(-24, 28, 48, 5), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-24, 28, 48 * clampf(hp / max_hp, 0, 1), 5), Color.LIME_GREEN)
