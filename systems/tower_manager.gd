## Owns the placed towers: building, selling, and which one is selected (range ring shown).
## Main handles gold and UI; this only keeps the towers and their path cells in sync.
class_name TowerManager
extends Node2D

var towers := {}                  # Vector2i -> Tower
var sel_cell := Vector2i(-1, -1)  # selected tower's cell, (-1,-1) = none
signal lost(cell: Vector2i)   # a tower was destroyed by enemies

var pathing: Pathing
var projectiles: Node


func setup(p: Pathing, projectile_parent: Node) -> void:
	pathing = p
	projectiles = projectile_parent


func add(kind: String, c: Vector2i) -> void:
	var t := Tower.new()
	t.setup(kind, projectiles)
	t.position = Config.cell_center(c)
	add_child(t)
	towers[c] = t
	t.destroyed.connect(func(_t: Tower) -> void: remove(c); lost.emit(c))
	pathing.set_blocked(c, true)


## Removes the tower and returns its sell value.
func remove(c: Vector2i) -> int:
	var t: Tower = towers[c]
	var value := t.sell_value()
	if c == sel_cell:
		deselect()
	t.queue_free()
	towers.erase(c)
	pathing.set_blocked(c, false)
	return value


## Gold cost of evolving the tower at `c` into branch `id`; -1 if not allowed.
func evolve_cost(c: Vector2i, id: String) -> int:
	var t: Tower = towers.get(c)
	return t.evolve_cost() if t != null and Evolutions.has(t.kind, id) else -1


func evolve(c: Vector2i, id: String) -> void:
	var t: Tower = towers[c]
	t.evolve(id, t.evolve_cost())


func heal_all() -> void:
	for t: Tower in towers.values():
		t.heal_full()


func select(c: Vector2i) -> void:
	deselect()
	sel_cell = c
	_show_range(c, true)


func deselect() -> void:
	if towers.has(sel_cell):
		_show_range(sel_cell, false)
	sel_cell = Vector2i(-1, -1)


func selected() -> Tower:
	return towers.get(sel_cell)


func _show_range(c: Vector2i, on: bool) -> void:
	var t: Tower = towers[c]
	t.show_range = on
	t.queue_redraw()
