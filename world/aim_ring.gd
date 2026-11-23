## Circle that follows the pointer while a targeted ability is armed (shows its blast radius).
class_name AimRing
extends Node2D

var radius := 0.0


func show_for(kind: String) -> void:
	radius = Abilities.TYPES[kind].get("radius", 0.0) if kind != "" else 0.0
	visible = radius > 0.0
	set_process(visible)


func _ready() -> void:
	show_for("")


func _process(_delta: float) -> void:
	position = get_parent().get_local_mouse_position()
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.8, 0.3, 0.15))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1.0, 0.85, 0.4, 0.9), 3.0)
