## What a hero looks like: feet-pivoted sprite (4 walk frames + attack pose), ground shadow,
## facing flip, level badge. Hero feeds it distance moved and attack events; no game rules here.
## Art: assets/art/gen/hero_<id>_walk_0..3.png / hero_<id>_attack.png, id = evolution or kind.
class_name HeroVisual
extends Node2D

static var _shadow_tex: GradientTexture2D

var sprite := Sprite2D.new()
var shadow := Sprite2D.new()
var height := Config.HERO_PX      # drawn height above the feet (HP bar sits above this)
var art_id := ""

var _walk: Array[Texture2D] = []
var _attack: Texture2D
var _phase := 0.0
var _amp := 0.0
var _facing := 1.0
var _attack_t := 0.0


## Load the art for `id` ("knight", "paladin", ...). Safe to call again after an evolution.
func set_art(id: String) -> void:
	if id == art_id:
		return
	art_id = id
	_walk.clear()
	for i in 4:
		_walk.append(load("res://assets/art/gen/hero_%s_walk_%d.png" % [id, i]))
	_attack = load("res://assets/art/gen/hero_%s_attack.png" % id)
	var sz := _walk[0].get_size()
	var sc := Config.HERO_PX / sz.y
	sprite.texture = _walk[0]
	sprite.scale = Vector2(sc, sc)
	sprite.offset = Vector2(0, -sz.y * 0.5)       # frames are bottom-aligned: feet on the origin
	if shadow.texture == null:
		shadow.texture = _get_shadow()
		shadow.position.y = -1.0
		add_child(shadow)
		add_child(sprite)
	shadow.scale = Vector2(sz.x * sc * 0.5, 14.0) / 64.0 * 2.0


static func _get_shadow() -> GradientTexture2D:
	if _shadow_tex == null:
		var g := Gradient.new()
		g.colors = PackedColorArray([Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.0)])
		g.offsets = PackedFloat32Array([0.0, 1.0])
		_shadow_tex = GradientTexture2D.new()
		_shadow_tex.gradient = g
		_shadow_tex.fill = GradientTexture2D.FILL_RADIAL
		_shadow_tex.fill_from = Vector2(0.5, 0.5)
		_shadow_tex.fill_to = Vector2(1.0, 0.5)
		_shadow_tex.width = 64
		_shadow_tex.height = 64
	return _shadow_tex


## Show the attack pose briefly, turning toward `dir_x` (the target's side).
func attack(dir_x: float) -> void:
	_attack_t = Config.HERO_ATTACK_POSE
	if absf(dir_x) > 1.0:
		_facing = 1.0 if dir_x > 0.0 else -1.0


## Every frame: `moved` = pixels walked this frame, `dir_x` = horizontal travel direction.
func advance(delta: float, moved: float, dir_x: float) -> void:
	var walking := moved > 0.01
	_amp = move_toward(_amp, 1.0 if walking else 0.0, delta * 8.0)
	_attack_t = maxf(0.0, _attack_t - delta)
	if walking:
		_phase += moved / Config.HERO_STRIDE
		if absf(dir_x) > 0.1 and _attack_t <= 0.0:
			_facing = 1.0 if dir_x > 0.0 else -1.0
	sprite.flip_h = _facing < 0.0
	if _attack_t > 0.0:
		sprite.texture = _attack
	elif walking:
		sprite.texture = _walk[int(_phase * 2.0) % 4]
	else:
		sprite.texture = _walk[0]
	# Small bob on each footfall; the attack frame gets a quick punch.
	var bob := absf(sin(_phase * PI)) * 0.04 * _amp
	var punch := _attack_t / Config.HERO_ATTACK_POSE * 0.08
	sprite.scale.y = absf(sprite.scale.x) * (1.0 + bob + punch * 0.5)
