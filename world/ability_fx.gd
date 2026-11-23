## One-shot visual for a cast ability (volley: arrows rain on a circle; freeze: icy screen pulse),
## plus a reticle that follows the pointer while a targeted ability is armed.
class_name AbilityFx
extends Node2D

var kind := ""
var radius := 0.0
var t := 0.0
const DURATION := 0.7


## Shows an effect for `Abilities.cast`.
static func play(parent: Node, kind_name: String, pos: Vector2, rad: float) -> void:
	var fx := AbilityFx.new()
	fx.kind = kind_name
	fx.radius = rad
	fx.position = pos
	parent.add_child(fx)


func _process(delta: float) -> void:
	t += delta / DURATION
	if t >= 1.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var a := 1.0 - t
	if kind == "volley":
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.8, 0.3, 0.18 * a))
		draw_arc(Vector2.ZERO, radius * minf(1.0, t * 3.0), 0, TAU, 48, Color(1.0, 0.85, 0.4, a), 4.0)
		for i in 18:
			var ang := i * 2.4
			var off := Vector2(cos(ang), sin(ang)) * radius * (0.15 + 0.8 * fmod(i * 0.37, 1.0))
			var fall := clampf(t * 2.5 - i * 0.03, 0.0, 1.0)
			var head := off + Vector2(0, -260.0 * (1.0 - fall))
			draw_line(head - Vector2(6, 26), head, Color(0.9, 0.85, 0.7, a), 3.0)
			draw_line(head, head + Vector2(0, 0), Color(0.5, 0.5, 0.5, a), 5.0)
	elif kind == "freeze":
		var c := Config.SCREEN / 2.0 - position
		draw_rect(Rect2(-position, Config.SCREEN), Color(0.45, 0.8, 1.0, 0.35 * a))
		draw_arc(c, 900.0 * t, 0, TAU, 64, Color(0.8, 0.95, 1.0, a), 10.0)
