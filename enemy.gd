class_name Enemy
extends Node2D

## Stats per kind. Art: assets/art/gen/enemy_<kind>.png, drawn `px` pixels on its longest side.
const KINDS := {
	"normal": {"speed": 65.0, "hp": 40.0, "reward": 5, "radius": 16.0, "atk": 8.0, "px": 46.0},
	"fast": {"speed": 110.0, "hp": 20.0, "reward": 4, "radius": 14.0, "atk": 6.0, "px": 54.0},
	"tank": {"speed": 40.0, "hp": 120.0, "reward": 12, "radius": 22.0, "atk": 20.0, "px": 66.0},
	"archer": {"speed": 55.0, "hp": 35.0, "reward": 7, "radius": 14.0, "atk": 6.0, "range": 170.0, "px": 48.0},
	"swarm": {"speed": 100.0, "hp": 10.0, "reward": 2, "radius": 10.0, "atk": 3.0, "px": 36.0},
	"boss": {"speed": 32.0, "hp": 500.0, "reward": 120, "radius": 32.0, "atk": 60.0, "px": 110.0},
}

signal died(enemy: Enemy)
signal hit_castle(damage: int)   # standing at the castle and hitting it

var pathing: Pathing
var points: Array[Vector2] = []
var target_idx := 0
var _progress := 0.0
var speed := 60.0
var max_hp := 30.0
var hp := 30.0
var reward := 5
var radius := 12.0
var slow_timer := 0.0
var dead := false
var kind := "normal"
var visual := EnemyVisual.new()
var atk_damage := 8.0     # damage to buildings per hit
var atk_cooldown := 0.0
var atk_range := 0.0      # >0: ranged, shoots towers/buildings in range while walking on
var at_castle := false    # reached the castle: stays and attacks until killed


func setup(path: Pathing, spawn: Vector2i, kind_name: String, wave: int) -> void:
	pathing = path
	kind = kind_name
	position = Config.cell_center(spawn)
	_repath()
	pathing.changed.connect(_repath)
	var st: Dictionary = KINDS.get(kind_name, KINDS.normal)
	var scale_hp := 1.0 + wave * 0.25 + wave * wave * 0.016
	speed = st.speed * minf(1.6, 1.0 + wave * 0.01)
	max_hp = st.hp * scale_hp
	reward = int(st.reward * (1.0 + wave * 0.04))
	radius = st.radius
	atk_damage = st.atk * (1.0 + wave * 0.08)
	atk_range = st.get("range", 0.0)
	hp = max_hp
	_build_visual(st.get("px", 48.0))
	add_to_group("enemies")


func _build_visual(px: float) -> void:
	visual.setup(kind, px)
	add_child(visual)


## Higher = closer to the castle. Towers target the highest.
func progress() -> float:
	return _progress


## Re-route from the current cell (spawn, or when buildings change).
func _repath() -> void:
	var p := pathing.route(Config.world_to_cell(position))
	if p.is_empty():
		return
	points = p
	target_idx = 0


func _remaining() -> float:
	if target_idx >= points.size():
		return 0.0
	var d := position.distance_to(points[target_idx])
	for i in range(target_idx, points.size() - 1):
		d += points[i].distance_to(points[i + 1])
	return d


func take_damage(amount: float, slow: float = 0.0) -> void:
	if dead:
		return
	hp -= amount
	if slow > 0.0:
		slow_timer = slow
	if hp <= 0.0:
		dead = true
		get_tree().call_group("sfx", "play_sfx", "enemy_die", -5.0)
		remove_from_group("enemies")
		died.emit(self)
		_become_corpse.call_deferred()
	else:
		queue_redraw()


## Game logic is done: leave the enemies list (so waves clear) and play the death anim.
func _become_corpse() -> void:
	var fx_parent := get_parent().get_parent()
	if fx_parent:
		reparent(fx_parent)
	queue_redraw()
	visual.play_death().finished.connect(queue_free)


func _process(delta: float) -> void:
	if dead:
		return
	var mult := 1.0
	if slow_timer > 0.0:
		slow_timer -= delta
		mult = 0.5
	atk_cooldown -= delta
	if at_castle:
		visual.advance(delta, 0.0, Vector2.ZERO, mult)
		_attack_castle()
		return
	if atk_range > 0.0:
		_shoot_nearby()
	if _attack_tower() or _attack_blocker():
		visual.advance(delta, 0.0, Vector2.ZERO, mult)
		queue_redraw()
		return
	var move := speed * mult * delta
	var start := position
	while move > 0.0 and target_idx < points.size():
		var to := points[target_idx] - position
		var d := to.length()
		# Cut corners: turn toward the next cell a little early instead of snapping to grid centres.
		var cut := Config.ENEMY_CORNER_RADIUS if target_idx < points.size() - 1 else 0.0
		if d <= move or d <= cut:
			if d <= move:
				position = points[target_idx]
				move -= d
			target_idx += 1
		else:
			position += to / d * move
			move = 0.0
	var step := position - start
	visual.advance(delta, step.length(), step.normalized(), mult)
	_progress = -_remaining()
	if target_idx >= points.size() or Config.is_castle(Config.world_to_cell(position)):
		at_castle = true
		_progress = 0.0
	queue_redraw()


## If the next cell on the route holds a building, stand and hit it. True = blocked.
func _attack_blocker() -> bool:
	if target_idx >= points.size():
		return false
	var b := pathing.building_at(Config.world_to_cell(points[target_idx])) as Building
	if b == null:
		return false
	if atk_cooldown <= 0.0:
		atk_cooldown = 1.0
		visual.lunge(b.position - position)
		b.take_damage(atk_damage)
	return true


## Standing at the castle: hit it once a second until a tower kills this enemy.
func _attack_castle() -> void:
	if atk_cooldown <= 0.0:
		atk_cooldown = 1.0
		visual.lunge(Config.ORIGIN + Vector2(Config.CASTLE_RECT.get_center()) * Config.TILE - position)
		hit_castle.emit(maxi(1, roundi(atk_damage * Config.CASTLE_DMG_FACTOR)))


## Melee raiders stop and hit any tower within reach until it falls. True = busy attacking.
func _attack_tower() -> bool:
	var t := _nearest_target(radius + 44.0, ["towers", "heroes"])
	if t == null:
		return false
	if atk_cooldown <= 0.0:
		atk_cooldown = 1.0
		visual.lunge(t.position - position)
		t.take_damage(atk_damage)
	return true


## Nearest tower/building within `reach`. `groups` = node groups to search; buildings are
## included when "buildings" is listed.
func _nearest_target(reach: float, groups: Array) -> Node2D:
	var best: Node2D = null
	var best_d := reach
	var pool: Array = []
	for g in groups:
		pool.append_array(pathing.occupants.values() if g == "buildings" else get_tree().get_nodes_in_group(g))
	for n in pool:
		if not is_instance_valid(n):
			continue
		var d := position.distance_to((n as Node2D).position)
		if d <= best_d:
			best_d = d
			best = n as Node2D
	return best


## Ranged raiders shoot the nearest tower or building within `atk_range` while still walking.
func _shoot_nearby() -> void:
	if atk_cooldown > 0.0:
		return
	var best := _nearest_target(atk_range, ["towers", "buildings", "heroes"])
	if best:
		atk_cooldown = 1.5
		visual.lunge(best.position - position)
		best.take_damage(atk_damage)
		get_tree().call_group("sfx", "play_sfx", "hit", -12.0)


func _draw() -> void:
	if dead:
		return
	var w := radius * 2.0
	var y := visual.position.y - visual.height - 8.0
	draw_rect(Rect2(-w / 2, y, w, 4), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-w / 2, y, w * clampf(hp / max_hp, 0, 1), 4), Color.LIME_GREEN)
