## Everything an enemy looks like: feet-pivoted sprite, soft ground shadow, step-synced
## squash/lean (or real walk frames), footstep dust, attack lunge and death fade.
## Enemy feeds it distance moved; with no movement it stands still (no bounce).
class_name EnemyVisual
extends Node2D

static var _shadow_tex: GradientTexture2D

var frames: EnemyFrames
var body := Node2D.new()          # pivot = feet; squash / lean / lunge applied here
var sprite := Sprite2D.new()
var shadow := Sprite2D.new()
var height := 40.0                # drawn height above the feet (for the HP bar)
var stride := Config.ENEMY_STRIDE
var tint := Color.WHITE

var _phase := randf() * 4.0       # grows by 1 per step walked
var _amp := 0.0                   # 0 standing .. 1 walking, eased
var _dir := Vector2.RIGHT         # smoothed travel direction
var _facing := 1.0                # +1 right, -1 left
var _next_hit_fx := 0.0           # msec timestamp: rate-limits hit sparks
var _radius := 16.0


func setup(kind: String, px: float) -> void:
	_radius = px * 0.35
	frames = EnemyFrames.new(kind)
	tint = frames.tint
	stride = Config.ENEMY_STRIDE * Config.ENEMY_STRIDE_MULT.get(kind, 1.0) * _radius / 16.0
	var tex_size := frames.textures[0].get_size()
	var sc := px / maxf(tex_size.x, tex_size.y)
	sprite.texture = frames.textures[0]
	sprite.scale = Vector2(sc, sc)
	sprite.position.y = -frames.feet_y * sc     # feet land exactly on the origin
	height = frames.art_h * sc
	position.y = height * 0.35                  # keep the body roughly centred on the path
	shadow.texture = _get_shadow()
	shadow.scale = Vector2(_radius * 2.6, _radius * 1.0) / 64.0
	shadow.position.y = -1.0
	add_child(shadow)
	body.add_child(sprite)
	add_child(body)


static func _get_shadow() -> GradientTexture2D:
	if _shadow_tex == null:
		var g := Gradient.new()
		g.colors = PackedColorArray([Color(0, 0, 0, 0.45), Color(0, 0, 0, 0.0)])
		g.offsets = PackedFloat32Array([0.0, 1.0])
		_shadow_tex = GradientTexture2D.new()
		_shadow_tex.gradient = g
		_shadow_tex.fill = GradientTexture2D.FILL_RADIAL
		_shadow_tex.fill_from = Vector2(0.5, 0.5)
		_shadow_tex.fill_to = Vector2(1.0, 0.5)
		_shadow_tex.width = 64
		_shadow_tex.height = 64
	return _shadow_tex


## Called every frame by Enemy. `moved` = pixels walked this frame, `dir` = unit direction.
func advance(delta: float, moved: float, dir: Vector2, speed_mult: float) -> void:
	var walking := moved > 0.01
	_amp = move_toward(_amp, 1.0 if walking else 0.0, delta * (8.0 if walking else 6.0))
	if walking:
		_dir = _dir.lerp(dir, minf(1.0, delta * 12.0)).normalized()
		if absf(_dir.x) > 0.25:
			_facing = 1.0 if _dir.x > 0.0 else -1.0
		var before := floorf(_phase)
		_phase += moved / stride
		if floorf(_phase) != before and int(_phase) % 2 == 0:
			FxSprite.play(_fx_parent(), "dust", global_position + Vector2(0, 1) - _dir * _radius * 0.4, _radius * 2.4, 12.0, Color(1, 1, 1, 0.6))
	sprite.flip_h = _facing < 0.0
	sprite.modulate = tint * (Color(0.6, 0.9, 1.0) if speed_mult < 1.0 else Color.WHITE)
	if frames.walk:
		sprite.texture = frames.textures[int(_phase * 2.0) % 4] if _amp > 0.05 else frames.textures[0]
	# Squash on each footfall + side sway; stronger when there are no walk frames.
	var k := (0.6 if frames.walk else 1.0) * _amp
	var c := cos(_phase * TAU)
	body.scale = Vector2(1.0 + 0.045 * k * c, 1.0 - 0.07 * k * c)
	body.rotation = _facing * (0.06 * k * sin(_phase * PI) + 0.1 * _dir.y * _amp)
	shadow.scale.x = _radius * 2.6 / 64.0 * (1.0 + 0.06 * k * c)


## Quick lunge toward `dir` (unit vector) for an attack.
func lunge(dir: Vector2) -> void:
	var t := create_tween()
	t.tween_property(body, "position", dir.normalized() * 9.0, 0.07)
	t.tween_property(body, "position", Vector2.ZERO, 0.14)


## Fade, shrink and burst into a death puff. Returns the tween; free the owner when it finishes.
func play_death() -> Tween:
	FxSprite.play(_fx_parent(), "death", global_position + Vector2(0, -height * 0.4), _radius * 4.0, 12.0)
	var t := create_tween().set_parallel(true)
	t.tween_property(body, "scale", Vector2(1.1, 0.8), Config.ENEMY_DEATH_TIME)
	t.tween_property(body, "modulate:a", 0.0, Config.ENEMY_DEATH_TIME)
	t.tween_property(shadow, "modulate:a", 0.0, Config.ENEMY_DEATH_TIME)
	return t


## Hit spark on the body, at most once per Config.FX_HIT_INTERVAL.
func hit_spark() -> void:
	var now := Time.get_ticks_msec()
	if now < _next_hit_fx:
		return
	_next_hit_fx = now + Config.FX_HIT_INTERVAL * 1000.0
	FxSprite.play(_fx_parent(), "hit", global_position + Vector2(0, -height * 0.5), _radius * 2.2, 24.0, Color(1, 1, 1, 0.9))


## Effects live next to the enemy (the enemy node itself may be freed first).
func _fx_parent() -> Node:
	return get_parent().get_parent() if get_parent() else null
