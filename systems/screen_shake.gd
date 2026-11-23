## Shakes a Node2D (the game world; HUD layers are unaffected). `shake(strength_px, seconds)`.
class_name ScreenShake
extends Node

var target: Node2D
var strength := 0.0
var left := 0.0
var total := 0.0


func shake(px: float, seconds: float) -> void:
	strength = px
	left = seconds
	total = seconds


func _process(delta: float) -> void:
	if target == null or left <= 0.0:
		return
	left -= delta
	var k := maxf(0.0, left / total)
	target.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * k if left > 0.0 else Vector2.ZERO
