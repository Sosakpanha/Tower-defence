## The castle the player defends. Owns its HP and draws itself.
class_name Castle
extends Node2D

signal damaged(hp: int)
signal destroyed

var hp := Config.CASTLE_HP


func _ready() -> void:
	position = Config.ORIGIN + Vector2(Config.CASTLE_RECT.position) * Config.TILE


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = maxi(0, hp - amount)
	damaged.emit(hp)
	queue_redraw()
	if hp == 0:
		destroyed.emit()


func _draw() -> void:
	var sz := Vector2(Config.CASTLE_RECT.size * Config.TILE)
	var stone := Color(0.62, 0.6, 0.58)
	var dark := Color(0.35, 0.33, 0.32)
	draw_rect(Rect2(6, 22, sz.x - 12, sz.y - 28), stone)
	draw_rect(Rect2(6, 22, sz.x - 12, sz.y - 28), dark, false, 3.0)
	for i in 4:  # battlements
		draw_rect(Rect2(10 + i * 32, 12, 18, 14), stone)
		draw_rect(Rect2(10 + i * 32, 12, 18, 14), dark, false, 2.0)
	for x in [4.0, sz.x - 30.0]:  # corner towers
		draw_rect(Rect2(x, 4, 26, sz.y - 10), stone.darkened(0.1))
		draw_rect(Rect2(x, 4, 26, sz.y - 10), dark, false, 3.0)
	draw_rect(Rect2(sz.x / 2 - 14, sz.y - 50, 28, 44), Color(0.3, 0.17, 0.08))  # gate
	draw_line(Vector2(sz.x / 2, 12), Vector2(sz.x / 2, -22), dark, 3.0)  # flag
	draw_rect(Rect2(sz.x / 2, -22, 22, 14), Color(0.8, 0.12, 0.12))
	var w := sz.x - 12
	draw_rect(Rect2(6, sz.y + 4, w, 6), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(6, sz.y + 4, w * float(hp) / Config.CASTLE_HP, 6), Color.LIME_GREEN)
