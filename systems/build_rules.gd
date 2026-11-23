## Where may something be built? Kingdom ground only, free, no enemy standing there,
## and the castle must stay reachable.
class_name BuildRules
extends Node

var pathing: Pathing
var towers: Callable   # () -> Dictionary of placed towers
var buildings: BuildingManager


func setup(path: Pathing, tower_dict: Callable, building_mgr: BuildingManager) -> void:
	pathing = path
	towers = tower_dict
	buildings = building_mgr


func can_build(c: Vector2i) -> bool:
	if not Config.in_grid(c) or Config.is_jungle(c) or Config.is_castle(c) or towers.call().has(c) or buildings.has(c):
		return false
	for e in get_tree().get_nodes_in_group("enemies"):
		if Config.world_to_cell(e.position) == c:
			return false
	return not pathing.would_block(c)
