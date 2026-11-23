## Pooled one-shot sprite effects from assets/art/gen/fx_<kind>_0..3.png (hit spark, death
## puff, footstep dust). Frames share a 128x110 canvas with the art bottom-aligned, so each
## kind has a pivot (canvas pixel that lands on the requested position).
## Usage: FxSprite.play(parent, "hit", world_pos, on_screen_width)
class_name FxSprite
extends Sprite2D

const PIVOT := {"hit": Vector2(64, 72), "death": Vector2(64, 88), "dust": Vector2(64, 104)}
const FRAMES := 4
const MAX_LIVE := 60              # swarm waves must stay cheap: extra effects are skipped
const CANVAS_W := 128.0

static var _tex := {}             # kind -> Array[Texture2D]
static var _pool: Array[FxSprite] = []
static var _live := 0

var _kind := ""
var _t := 0.0
var _fps := 14.0


static func play(parent: Node, kind: String, pos: Vector2, width: float, fps := 14.0, tint := Color.WHITE) -> void:
	if parent == null or _live >= MAX_LIVE:
		return
	var fx: FxSprite = null
	while not _pool.is_empty() and fx == null:
		var c: FxSprite = _pool.pop_back()
		if is_instance_valid(c):
			fx = c
	if fx == null:
		fx = FxSprite.new()
		fx.centered = false
	fx._start(parent, kind, pos, width, fps, tint)


static func _textures(kind: String) -> Array:
	if not _tex.has(kind):
		var a: Array[Texture2D] = []
		for i in FRAMES:
			a.append(load("res://assets/art/gen/fx_%s_%d.png" % [kind, i]))
		_tex[kind] = a
	return _tex[kind]


func _start(parent: Node, kind: String, pos: Vector2, width: float, fps: float, tint: Color) -> void:
	_kind = kind
	_t = 0.0
	_fps = fps
	var s := width / CANVAS_W
	scale = Vector2(s, s)
	offset = -PIVOT[kind]
	modulate = tint
	texture = _textures(kind)[0]
	if get_parent() != parent:
		if get_parent():
			get_parent().remove_child(self)
		parent.add_child(self)
	global_position = pos
	visible = true
	set_process(true)
	_live += 1


func _exit_tree() -> void:
	if visible:     # freed with the scene mid-play
		visible = false
		_live -= 1


func _process(delta: float) -> void:
	_t += delta * _fps
	var i := int(_t)
	if i >= FRAMES:
		visible = false
		set_process(false)
		_live -= 1
		_pool.append(self)
		return
	texture = _textures(_kind)[i]
