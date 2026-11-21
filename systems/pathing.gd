## Grid pathfinding from any cell to the castle. Buildings are solid cells.
## Emits `changed` whenever the obstacles change so enemies can re-route.
class_name Pathing
extends RefCounted

signal changed

## Path cost of walking "through" a building (enemies must chew through it). Towers stay solid.
const BUILDING_WEIGHT := 6.0

var grid := AStarGrid2D.new()
var occupants := {}  # Vector2i -> building node that enemies may attack


func _init() -> void:
	grid.region = Rect2i(0, 0, Config.COLS, Config.ROWS)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()


func set_blocked(c: Vector2i, blocked: bool) -> void:
	grid.set_point_solid(c, blocked)
	changed.emit()


## A building is not solid but expensive: enemies detour if cheap, else attack through it.
func set_building(c: Vector2i, building: Node) -> void:
	if building:
		occupants[c] = building
	else:
		occupants.erase(c)
	grid.set_point_weight_scale(c, BUILDING_WEIGHT if building else 1.0)
	changed.emit()


func building_at(c: Vector2i) -> Node:
	var b: Node = occupants.get(c)
	return b if is_instance_valid(b) else null


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
