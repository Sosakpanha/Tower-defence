## The hero unit on the map: walks where told, auto-attacks enemies, has HP.
## Stats come from core/heroes.gd; HeroManager owns level/kills/respawn. Drawn in code.
class_name Hero
extends Node2D

signal damaged
signal died

const AGGRO := 140.0     # melee heroes with no order chase enemies this close
const HIT_RADIUS := 38.0 # tap this close to select the hero

var kind := "knight"
var stats := {}
var hp := 1.0
var max_hp := 1.0
var level := 1
var evo := ""
var selected := false
var move_target := Vector2.INF
var projectile_parent: Node
var cooldown := 0.0
var swing := 0.0
var _heal_t := 0.0


func setup(k: String, proj_parent: Node) -> void:
	kind = k
	projectile_parent = proj_parent
	add_to_group("heroes")


## Recompute stats after a level-up/evolution; keeps the current HP fraction.
func apply(e: String, lv: int, full_heal: bool = false) -> void:
	var frac := hp / max_hp
	evo = e
	level = lv
	stats = Heroes.stats(kind, evo, lv)
	max_hp = stats.hp
	hp = max_hp if full_heal else max_hp * frac
	queue_redraw()


func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	damaged.emit()
	queue_redraw()
	if hp <= 0.0:
		died.emit()


func _process(delta: float) -> void:
	cooldown -= delta
	swing = maxf(0.0, swing - delta * 5.0)
	if stats.regen > 0.0 and hp < max_hp:
		hp = minf(max_hp, hp + stats.regen * delta)
	_heal_towers(delta)
	var target := _nearest_enemy(stats.range)
	if move_target != Vector2.INF:
		_walk_to(move_target, delta)
		if position.distance_to(move_target) < 4.0:
			move_target = Vector2.INF
	elif target == null and stats.melee:
		var chase := _nearest_enemy(AGGRO)
		if chase:
			_walk_to(chase.position, delta)
	if target and cooldown <= 0.0:
		cooldown = stats.rate
		_attack(target)
	queue_redraw()


func _walk_to(p: Vector2, delta: float) -> void:
	position = position.move_toward(p, stats.speed * delta)
	var lo := Config.ORIGIN + Vector2(Config.TILE, Config.TILE) * 0.5
	var hi := Config.ORIGIN + Vector2(Config.COLS, Config.ROWS) * Config.TILE - Vector2(Config.TILE, Config.TILE) * 0.5
	position = position.clamp(lo, hi)


func _nearest_enemy(reach: float) -> Enemy:
	var best: Enemy = null
	var best_d := reach
	for n in get_tree().get_nodes_in_group("enemies"):
		var en := n as Enemy
		var d := en.position.distance_to(position)
		if not en.dead and d <= best_d:
			best_d = d
			best = en
	return best


func _attack(target: Enemy) -> void:
	if stats.melee:
		swing = 1.0
		target.take_damage(stats.dmg)
		get_tree().call_group("sfx", "play_sfx", "hit", -8.0)
		return
	var p := Projectile.new()
	p.position = position
	p.target = target
	p.damage = stats.dmg
	p.splash = stats.splash
	p.color = stats.color
	p.texture = load("res://assets/art/proj_gunner.svg")
	projectile_parent.add_child(p)
	get_tree().call_group("sfx", "play_sfx", "shoot_gunner", -10.0)


func _heal_towers(delta: float) -> void:
	_heal_t += delta
	if stats.heal <= 0.0 or _heal_t < 0.5:
		return
	for t: Tower in get_tree().get_nodes_in_group("towers"):
		if t.hp < t.max_hp and t.position.distance_to(position) <= 150.0:
			t.hp = minf(t.max_hp, t.hp + stats.heal * _heal_t)
			t.queue_redraw()
	_heal_t = 0.0


func _draw() -> void:
	var col: Color = stats.color
	if selected:
		draw_arc(Vector2.ZERO, 26.0, 0, TAU, 32, Color(1, 1, 0.4, 0.9), 3.0)
		if move_target != Vector2.INF:
			draw_circle(move_target - position, 6.0, Color(1, 1, 0.4, 0.6))
	draw_circle(Vector2(0, 4), 17.0, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, 16.0, col)
	draw_arc(Vector2.ZERO, 16.0, 0, TAU, 24, Color(0.15, 0.08, 0.02), 3.0)
	if kind == "knight":   # sword, swings when attacking
		var a := -0.8 + swing * 1.6
		draw_line(Vector2.from_angle(a) * 8.0, Vector2.from_angle(a) * 28.0, Color(0.9, 0.9, 0.95), 4.0)
		draw_rect(Rect2(-6, -6, 12, 12), Color(0.2, 0.2, 0.35, 0.8), false, 2.0)
	else:                  # bow
		draw_arc(Vector2(6, 0), 14.0, -1.2, 1.2, 12, Color(0.45, 0.28, 0.1), 3.0)
		draw_line(Vector2(6 + cos(1.2) * 14.0, sin(-1.2) * 14.0), Vector2(6 + cos(1.2) * 14.0, sin(1.2) * 14.0), Color.WHITE, 1.0)
	if evo != "":   # evolution badge
		draw_circle(Vector2(-14, -16), 5.0, Color(1, 0.85, 0.2))
	for i in level:
		draw_circle(Vector2((i - (level - 1) / 2.0) * 8.0, 24.0), 2.5, Color(1.0, 0.85, 0.2))
	draw_rect(Rect2(-22, -32, 44, 5), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-22, -32, 44 * clampf(hp / max_hp, 0, 1), 5), Color.DEEP_SKY_BLUE)
