## On-map boss indicator: name tag + HP bar above each boss enemy, and an edge arrow
## when the boss is outside the visible field. Reads the "enemies" group only; ignores the mouse.
class_name BossMarker
extends CanvasLayer

const BAR := Vector2(96, 10)
const EDGE := Rect2(24, 104, 1232, 592)   # arrows are clamped inside this rect (below the HUD bar)

var canvas := Canvas.new()


func _ready() -> void:
	add_child(canvas)


func _process(_d: float) -> void:
	canvas.bosses = get_tree().get_nodes_in_group("enemies").filter(
		func(e: Node) -> bool: return e.get("kind") == "boss" and not e.get("dead"))
	if not canvas.bosses.is_empty() or canvas.drawn:
		canvas.queue_redraw()


class Canvas extends Control:
	var bosses: Array = []
	var drawn := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		drawn = not bosses.is_empty()
		var pulse := 0.65 + 0.35 * sin(Time.get_ticks_msec() / 160.0)
		for b: Node2D in bosses:
			var p := b.global_position
			_tag(p, b)
			if not EDGE.has_point(p):
				_arrow(p, pulse)

	func _tag(p: Vector2, b: Node2D) -> void:
		var y := maxf(p.y - float(b.radius) - 62.0, 92.0)   # keep it out of the HUD bar
		var x := clampf(p.x, 70.0, Config.SCREEN.x - 70.0)
		var font := ThemeDB.fallback_font
		var r := Rect2(x - BAR.x / 2.0, y + 20.0, BAR.x, BAR.y)
		draw_rect(Rect2(x - 56, y - 2, 112, 20), Color(0.25, 0.0, 0.0, 0.85))
		draw_string(font, Vector2(x - 56, y + 13), Config.KIND_NAMES.boss.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 112, 15, Color(1, 0.85, 0.7))
		draw_rect(r.grow(2), Color.BLACK)
		draw_rect(r, Color(0.35, 0.05, 0.05))
		var f := clampf(float(b.hp) / maxf(float(b.max_hp), 1.0), 0.0, 1.0)
		draw_rect(Rect2(r.position, Vector2(r.size.x * f, r.size.y)), Color(0.9, 0.15, 0.12))
		draw_colored_polygon(PackedVector2Array([Vector2(x - 7, r.end.y + 4), Vector2(x + 7, r.end.y + 4), Vector2(x, r.end.y + 12)]), Color(0.9, 0.15, 0.12))

	func _arrow(p: Vector2, pulse: float) -> void:
		var q := Vector2(clampf(p.x, EDGE.position.x, EDGE.end.x), clampf(p.y, EDGE.position.y, EDGE.end.y))
		var dir := (p - q).normalized()
		var side := Vector2(-dir.y, dir.x)
		draw_colored_polygon(PackedVector2Array([q + dir * 16, q - dir * 8 + side * 14, q - dir * 8 - side * 14]), Color(1.0, 0.25, 0.2, pulse))
