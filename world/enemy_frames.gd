## Picks the best art for an enemy and measures where its feet are.
## Priority: gen walk frames (enemy_<kind>_walk_0..3.png) -> single gen sprite
## (enemy_<kind>.png, procedural bob only) -> legacy 4-frame set in assets/enemies/.
class_name EnemyFrames
extends RefCounted

const GEN := "res://assets/art/gen/enemy_%s%s.png"
const LEGACY := {"normal": "goblin", "fast": "wolf", "tank": "ogre"}

static var _rect_cache := {}

var textures: Array[Texture2D] = []
var walk := false      # true when the 4 textures are a real walk cycle
var tint := Color.WHITE
var feet_y := 0.0      # bottom of the art, in texture pixels from the texture centre
var art_h := 1.0       # opaque height in pixels


func _init(kind: String) -> void:
	for i in 4:
		var p := GEN % [kind, "_walk_%d" % i]
		if ResourceLoader.exists(p):
			textures.append(load(p))
	walk = textures.size() == 4
	if not walk:
		textures.clear()
		var single := GEN % [kind, ""]
		if ResourceLoader.exists(single):
			for i in 4:
				textures.append(load(single))
		else:
			var art: String = LEGACY.get(kind, "goblin")
			if not ResourceLoader.exists("res://assets/enemies/%s/%s_00.png" % [art, art]):
				art = "goblin"
				tint = Color(1.0, 0.85, 0.3)
			for i in 4:
				textures.append(load("res://assets/enemies/%s/%s_%02d.png" % [art, art, i]))
			walk = true
	var tex := textures[0]
	var path := tex.resource_path
	if not _rect_cache.has(path):
		_rect_cache[path] = tex.get_image().get_used_rect()
	var r: Rect2i = _rect_cache[path]
	feet_y = r.end.y - tex.get_size().y / 2.0
	art_h = maxf(1.0, float(r.size.y))
