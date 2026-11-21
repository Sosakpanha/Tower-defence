## Highlights the tile under the mouse and shows tower range circles.
## `game` is the Main node (needs: map, towers, selected, gold, game_over).
class_name PlacementPreview
extends Node2D

const TEX_MARKER := preload("res://assets/tiles/buildable_marker.png")

var game: Node
var pending := Vector2i(-1, -1)  # touch: cell awaiting a confirming second tap


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if game == null or game.game_over:
		return
	var c: Vector2i = pending if Config.in_grid(pending) else game.map.mouse_cell()
	if not Config.in_grid(c):
		return
	var cost: int = Tower.TYPES[game.selected].cost
	var ok: bool = not game.map.is_path(c) and not game.towers.has(c) and game.gold >= cost
	var r: Rect2 = game.map.cell_rect(c)
	draw_texture_rect(TEX_MARKER, r, false, Color(1, 1, 1, 0.7))
	draw_rect(r, Color(0, 1, 0, 0.25) if ok else Color(1, 0, 0, 0.35))
	var ring := Color(1, 1, 1, 0.5)
	if game.towers.has(c):
		draw_arc(Config.cell_center(c), game.towers[c].get_range(), 0, TAU, 64, ring, 2.0)
	elif ok:
		draw_arc(Config.cell_center(c), Tower.TYPES[game.selected].range, 0, TAU, 64, ring, 2.0)
