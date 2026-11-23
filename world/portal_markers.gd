## Pulsing red ring and inward-pointing arrow on the portals the next wave will use.
class_name PortalMarkers
extends Node2D

var cells: Array[Vector2i] = []
var t := 0.0


func set_cells(c: Array[Vector2i]) -> void:
	cells = c
	set_process(not cells.is_empty())
	queue_redraw()


func _ready() -> void:
	z_index = 5


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(t * 5.0)
	var mid := Config.cell_center(Vector2i(Config.COLS / 2, Config.ROWS / 2))
	for c in cells:
		var p := Config.cell_center(c)
		draw_arc(p, 30.0 + pulse * 6.0, 0, TAU, 32, Color(1.0, 0.25, 0.2, 0.9 - pulse * 0.4), 4.0)
		var dir := (mid - p).normalized()
		var tip := p + dir * (46.0 + pulse * 8.0)
		var side := dir.orthogonal()
		draw_colored_polygon(PackedVector2Array([tip, tip - dir * 18.0 + side * 11.0, tip - dir * 18.0 - side * 11.0]), Color(1.0, 0.3, 0.2, 0.95))
