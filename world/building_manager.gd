## Registry of placed buildings plus population accounting. Emits signals; Main handles gold.
class_name BuildingManager
extends Node2D

signal income(amount: int)
signal changed          # building added/removed/destroyed (population may have changed)
signal destroyed(building: Building)

var buildings := {}     # Vector2i -> Building
var pathing: Pathing


func setup(path: Pathing) -> void:
	pathing = path


func has(c: Vector2i) -> bool:
	return buildings.has(c)


func pop_used() -> int:
	var n := 0
	for b: Building in buildings.values():
		n += b.stats.pop_use
	return n


func pop_cap() -> int:
	var n := Config.BASE_POP
	for b: Building in buildings.values():
		n += b.stats.pop_cap
	return n


func can_afford_pop(kind: String) -> bool:
	return pop_used() + Buildings.TYPES[kind].pop_use <= pop_cap()


func add(kind: String, c: Vector2i) -> void:
	var b := Building.new()
	b.setup(kind, c)
	b.produced.connect(func(amount: int, _b: Building) -> void: income.emit(amount))
	b.destroyed.connect(_on_destroyed)
	add_child(b)
	buildings[c] = b
	pathing.set_blocked(c, true)
	changed.emit()


## Removes the building at `c` (sold). Returns its refund value.
func remove(c: Vector2i) -> int:
	if not buildings.has(c):
		return 0
	var b: Building = buildings[c]
	var refund := int(b.stats.cost * Config.SELL_REFUND)
	buildings.erase(c)
	pathing.set_blocked(c, false)
	b.queue_free()
	changed.emit()
	return refund


func _on_destroyed(b: Building) -> void:
	buildings.erase(b.cell)
	pathing.set_blocked(b.cell, false)
	destroyed.emit(b)
	changed.emit()
