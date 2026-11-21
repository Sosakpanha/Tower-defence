## The castle the player defends. Owns its HP and draws itself.
class_name Castle
extends Node2D

signal damaged(hp: int)
signal destroyed

const TEX := preload("res://assets/art/castle.svg")

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
	draw_texture_rect(TEX, Rect2(Vector2.ZERO, sz), false)
	var w := sz.x - 12
	draw_rect(Rect2(6, sz.y + 4, w, 6), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(6, sz.y + 4, w * float(hp) / Config.CASTLE_HP, 6), Color.LIME_GREEN)
