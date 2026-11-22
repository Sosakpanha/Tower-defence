class_name Tower
extends Node2D

const TYPES := {
	"gunner": {"name": "Gunner", "cost": 50, "range": 150.0, "rate": 0.5, "damage": 10.0, "slow": 0.0, "color": Color.DODGER_BLUE},
	"sniper": {"name": "Sniper", "cost": 100, "range": 300.0, "rate": 1.6, "damage": 60.0, "slow": 0.0, "color": Color.FOREST_GREEN},
	"frost": {"name": "Frost", "cost": 75, "range": 130.0, "rate": 0.8, "damage": 4.0, "slow": 1.5, "color": Color.LIGHT_SKY_BLUE},
	# Splash damage.
	"cannon": {"name": "Cannon", "cost": 120, "range": 170.0, "rate": 1.8, "damage": 28.0, "slow": 0.0, "splash": 75.0, "color": Color.ORANGE},
}

var kind := "gunner"
var stats: Dictionary
var cooldown := 0.0
var angle := 0.0
var show_range := false
var recoil := 0.0
var level := 1
var spent := 0
const MAX_LEVEL := 3
const DMG_MULT := [1.0, 1.6, 2.4]
const RANGE_MULT := [1.0, 1.1, 1.2]
const RATE_MULT := [1.0, 0.85, 0.7]
signal destroyed(tower: Tower)

const HP_MULT := [1.0, 1.5, 2.0]
var max_hp := Config.TOWER_HP
var hp := Config.TOWER_HP
var projectile_parent: Node
var body: Sprite2D
var _base_scale := 1.0


func setup(k: String, proj_parent: Node) -> void:
	kind = k
	stats = TYPES[k]
	spent = stats.cost
	projectile_parent = proj_parent
	add_to_group("towers")
	body = Sprite2D.new()   # the finished tower picture; it kicks back a little when firing
	body.texture = load("res://assets/art/gen/tower_%s.png" % k)
	_base_scale = 62.0 / maxf(body.texture.get_width(), body.texture.get_height())
	body.scale = Vector2.ONE * _base_scale
	body.position = Vector2(0, 2)
	add_child(body)


func get_damage() -> float:
	return stats.damage * DMG_MULT[level - 1]


func get_range() -> float:
	return stats.range * RANGE_MULT[level - 1]


func get_rate() -> float:
	return stats.rate * RATE_MULT[level - 1]


func upgrade_cost() -> int:
	return -1 if level >= MAX_LEVEL else int(stats.cost * 0.6 * level)


func sell_value() -> int:
	return int(spent * Config.SELL_REFUND)


func upgrade() -> void:
	spent += upgrade_cost()
	level += 1
	var new_max: float = Config.TOWER_HP * HP_MULT[level - 1]
	hp += new_max - max_hp
	max_hp = new_max
	body.scale = Vector2.ONE * _base_scale * (1.0 + 0.06 * (level - 1))
	queue_redraw()


func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	queue_redraw()
	if hp <= 0.0:
		destroyed.emit(self)


func heal_full() -> void:
	hp = max_hp
	queue_redraw()


func _process(delta: float) -> void:
	cooldown -= delta
	if recoil > 0.0:
		recoil = maxf(0.0, recoil - delta * 40.0)
		body.position = Vector2(0, 2) - Vector2.from_angle(angle) * recoil
	var best: Enemy = null
	var best_p := -INF
	for e in get_tree().get_nodes_in_group("enemies"):
		var en := e as Enemy
		if en.dead or en.position.distance_to(position) > get_range():
			continue
		if en.progress() > best_p:
			best_p = en.progress()
			best = en
	if best:
		angle = (best.position - position).angle()
		if cooldown <= 0.0:
			cooldown = get_rate()
			var p := Projectile.new()
			p.position = position + Vector2.from_angle(angle) * 20.0
			p.target = best
			p.damage = get_damage()
			p.slow = stats.slow
			p.splash = stats.get("splash", 0.0)
			p.color = stats.color
			recoil = 5.0
			p.texture = load("res://assets/art/proj_%s.svg" % kind)
			projectile_parent.add_child(p)
			get_tree().call_group("sfx", "play_sfx", "shoot_" + kind, -9.0)


func _draw() -> void:
	if hp < max_hp:
		draw_rect(Rect2(-24, -36, 48, 5), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-24, -36, 48 * clampf(hp / max_hp, 0, 1), 5), Color.ORANGE_RED)
	if show_range:
		draw_arc(Vector2.ZERO, get_range(), 0, TAU, 64, Color(1, 1, 1, 0.5), 2.0)
	for i in level:
		var pos := Vector2((i - (level - 1) / 2.0) * 12.0, 27.0)
		draw_circle(pos, 4.5, Color(0.2, 0.1, 0.03))
		draw_circle(pos, 3.0, Color(1.0, 0.85, 0.2))
