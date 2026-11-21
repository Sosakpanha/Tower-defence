## Grid pathfinding from any cell to the castle. Buildings are solid cells.
## Emits `changed` whenever the obstacles change so enemies can re-route.
class_name Pathing
extends RefCounted

signal changed

var grid := AStarGrid2D.new()


func _init() -> void:
	grid.region = Rect2i(0, 0, Config.COLS, Config.ROWS)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()


func set_blocked(c: Vector2i, blocked: bool) -> void:
	grid.set_point_solid(c, blocked)
	changed.emit()


## World-space waypoints (cell centers) from `from` to the castle. Empty if unreachable.
func route(from: Vector2i) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for c in grid.get_id_path(from, Config.CASTLE_RECT.position):
		out.append(Config.cell_center(c))
	return out


## True if blocking `c` would leave some spawn with no way to the castle.
func would_block(c: Vector2i) -> bool:
	if grid.is_point_solid(c):
		return false
	grid.set_point_solid(c, true)
	var blocked := false
	for s in Config.SPAWN_CELLS:
		if grid.get_id_path(s, Config.CASTLE_RECT.position).is_empty():
			blocked = true
			break
	grid.set_point_solid(c, false)
	return blocked
