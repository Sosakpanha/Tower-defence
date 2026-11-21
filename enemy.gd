class_name Enemy
extends Node2D

signal died(enemy: Enemy)
signal reached_end(enemy: Enemy)  # reached the castle

var pathing: Pathing
var points: Array[Vector2] = []
var target_idx := 0
var _progress := 0.0
var speed := 60.0
var max_hp := 30.0
var hp := 30.0
var reward := 5
var radius := 12.0
var color := Color.TOMATO
var slow_timer := 0.0
var dead := false
var kind := "normal"
var sprite := AnimatedSprite2D.new()
var base_tint := Color.WHITE
var atk_damage := 8.0     # damage to buildings per hit
var atk_cooldown := 0.0


func setup(path: Pathing, spawn: Vector2i, kind_name: String, wave: int) -> void:
	pathing = path
	kind = kind_name
	position = Config.cell_center(spawn)
	_repath()
	pathing.changed.connect(_repath)
	var scale_hp := 1.0 + wave * 0.35
	match kind_name:
		"fast":
			speed = 110.0; max_hp = 20.0 * scale_hp; reward = 4; radius = 14.0; color = Color.GOLD
		"tank":
			speed = 40.0; max_hp = 120.0 * scale_hp; reward = 12; radius = 22.0; color = Color.DARK_ORCHID
		_:
			speed = 65.0; max_hp = 40.0 * scale_hp; reward = 5; radius = 16.0; color = Color.TOMATO
	hp = max_hp
	_build_sprite(kind)
	add_to_group("enemies")


func _build_sprite(kind: String) -> void:
	var art: String = {"normal": "goblin", "fast": "wolf", "tank": "ogre"}[kind]
	var tint := Color.WHITE
	var sc := 1.0
	var fps := {"goblin": 8.0, "wolf": 12.0, "ogre": 6.0}
	# Fallback until wolf art exists: tinted, smaller goblin.
	if not ResourceLoader.exists("res://assets/enemies/%s/%s_00.png" % [art, art]):
		art = "goblin"; tint = Color(1.0, 0.85, 0.3); sc = 0.8
		fps["goblin"] = 12.0
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", fps[art])
	for i in 4:
		frames.add_frame("default", load("res://assets/enemies/%s/%s_%02d.png" % [art, art, i]))
	sprite.sprite_frames = frames
	base_tint = tint
	sprite.scale = Vector2(sc, sc)
	sprite.play("default")
	sprite.frame = randi() % 4
	add_child(sprite)


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
		died.emit(self)
		queue_free()
	else:
		queue_redraw()


func _process(delta: float) -> void:
	if dead:
		return
	var mult := 1.0
	if slow_timer > 0.0:
		slow_timer -= delta
		mult = 0.5
	sprite.speed_scale = mult
	sprite.modulate = base_tint * Color(0.6, 0.9, 1.0) if slow_timer > 0.0 else base_tint
	atk_cooldown -= delta
	if _attack_blocker():
		queue_redraw()
		return
	var move := speed * mult * delta
	while move > 0.0 and target_idx < points.size():
		var to := points[target_idx] - position
		var d := to.length()
		if d <= move:
			position = points[target_idx]
			target_idx += 1
			move -= d
		else:
			position += to / d * move
			if absf(to.x) > 1.0:
				sprite.flip_h = to.x < 0.0
			move = 0.0
	_progress = -_remaining()
	if target_idx >= points.size() or Config.is_castle(Config.world_to_cell(position)):
		dead = true
		reached_end.emit(self)
		queue_free()
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
		b.take_damage(atk_damage)
	return true


func _draw() -> void:
	var w := radius * 2.0
	var y := -radius - 6.0
	draw_rect(Rect2(-w / 2, y, w, 4), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-w / 2, y, w * clampf(hp / max_hp, 0, 1), 4), Color.LIME_GREEN)
