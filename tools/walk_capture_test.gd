# Usage: Godot --path . --fixed-fps 60 --script tools/walk_capture_test.gd   (needs a window)
# Walks one of each enemy kind across open ground with ground tick marks, and saves a
# filmstrip per kind (crop follows the enemy, so foot sliding shows against the ticks):
# shots/walk_<kind>.png, plus shots/walk_crowd.png (many enemies at once).
extends SceneTree

const KINDS := ["normal", "fast", "tank", "archer", "swarm", "boss"]
const EVERY := 5
const COUNT := 8
const CROP := Vector2i(100, 100)

var holders := {}
var strips := {}
var frame := 0
var ground: Node2D


class Ground extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 2400, 900), Color(0.3, 0.45, 0.2))
		for x in range(0, 2400, 20):
			draw_line(Vector2(x, 0), Vector2(x, 900), Color(0, 0, 0, 0.6 if x % 100 else 1.0), 1.0)


func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	ground = Ground.new()
	root.add_child(ground)
	for i in KINDS.size():
		var k: String = KINDS[i]
		var h := Node2D.new()
		h.position = Vector2(60, 100 + i * 120)
		var v := EnemyVisual.new()
		v.setup(k, Enemy.KINDS[k].px)
		h.add_child(v)
		ground.add_child(h)
		holders[k] = [h, v]
		strips[k] = []
	for j in 12:   # a crowd for the full shot
		var h := Node2D.new()
		h.position = Vector2(700 + (j % 4) * 110, 100 + (j / 4) * 150 + (j % 2) * 30)
		var k: String = KINDS[j % KINDS.size()]
		var v := EnemyVisual.new()
		v.setup(k, Enemy.KINDS[k].px)
		h.add_child(v)
		ground.add_child(h)
		holders["c%d" % j] = [h, v, k]


func _process(delta: float) -> bool:
	frame += 1
	var d := 1.0 / 60.0
	for key in holders:
		var h: Node2D = holders[key][0]
		var v: EnemyVisual = holders[key][1]
		var spd: float = Enemy.KINDS[key if not key.begins_with("c") else holders[key][2]].speed
		var step := spd * d
		h.position.x += step
		v.advance(d, step, Vector2.RIGHT, 1.0)
		if key.begins_with("c") and frame in [38, 41]:
			v.hit_spark()
			if key == "c1" and frame == 41:
				v.play_death()
	if frame > 5 and frame % EVERY == 0 and strips["normal"].size() < COUNT:
		var img := root.get_texture().get_image()
		for k in KINDS:
			var c: Vector2 = holders[k][0].position
			var r := Rect2i(Vector2i(c) - Vector2i(CROP.x / 2, CROP.y - 20), CROP)
			strips[k].append(img.get_region(r))
	if strips["normal"].size() >= COUNT:
		if frame % EVERY == 0:
			root.get_texture().get_image().get_region(Rect2i(0, 0, 1280, 720)).save_png("res://shots/walk_crowd.png")
		for k in KINDS:
			var out := Image.create(CROP.x * COUNT, CROP.y, false, Image.FORMAT_RGBA8)
			for i in COUNT:
				out.blit_rect(strips[k][i], Rect2i(Vector2i.ZERO, CROP), Vector2i(i * CROP.x, 0))
			out.resize(out.get_width() * 2, out.get_height() * 2, Image.INTERPOLATE_NEAREST)
			out.save_png("res://shots/walk_%s.png" % k)
		print("WALK shots saved")
		quit()
	return false
