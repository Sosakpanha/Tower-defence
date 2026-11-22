# Cuts an AI-generated sprite sheet (flat grey background) into transparent PNGs.
# Usage: Godot --headless --path . --script tools/slice_sheet.gd -- <sheet.png> <out_dir> <cols> <max_px> name1 name2 ...
# Names are in reading order (left to right, top to bottom). Sprites are scaled so the longest side = max_px.
extends SceneTree

const TOL := 0.13       # colour distance from the background that still counts as background
const MIN_AREA := 600   # ignore specks smaller than this (px)
const MERGE := 14       # boxes closer than this belong to the same sprite


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var out_dir := a[1]
	var cols := int(a[2])
	var max_px := int(a[3])
	var names := a.slice(4)
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(4, 4).lerp(img.get_pixel(w - 5, 4), 0.5)
	var is_bg := PackedByteArray(); is_bg.resize(w * h)
	var stack: Array[Vector2i] = []
	for x in w:
		stack.append(Vector2i(x, 0)); stack.append(Vector2i(x, h - 1))
	for y in h:
		stack.append(Vector2i(0, y)); stack.append(Vector2i(w - 1, y))
	while not stack.is_empty():   # flood fill the background from the border
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or is_bg[p.y * w + p.x] == 1:
			continue
		var c := img.get_pixel(p.x, p.y)
		if absf(c.r - bg.r) + absf(c.g - bg.g) + absf(c.b - bg.b) > TOL * 3.0:
			continue
		is_bg[p.y * w + p.x] = 1
		stack.append(Vector2i(p.x + 1, p.y)); stack.append(Vector2i(p.x - 1, p.y))
		stack.append(Vector2i(p.x, p.y + 1)); stack.append(Vector2i(p.x, p.y - 1))
	for y in h:
		for x in w:
			if is_bg[y * w + x] == 1:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	# connected components of what is left -> bounding boxes
	var seen := PackedByteArray(); seen.resize(w * h)
	var boxes: Array[Rect2i] = []
	var areas: Array[int] = []
	for y in h:
		for x in w:
			if is_bg[y * w + x] == 1 or seen[y * w + x] == 1:
				continue
			var q: Array[Vector2i] = [Vector2i(x, y)]
			seen[y * w + x] = 1
			var r := Rect2i(x, y, 1, 1)
			var n := 0
			while not q.is_empty():
				var p: Vector2i = q.pop_back()
				n += 1
				r = r.expand(p)
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var t: Vector2i = p + d
					if t.x >= 0 and t.y >= 0 and t.x < w and t.y < h and is_bg[t.y * w + t.x] == 0 and seen[t.y * w + t.x] == 0:
						seen[t.y * w + t.x] = 1
						q.append(t)
			if n >= MIN_AREA:
				boxes.append(Rect2i(r.position, r.size + Vector2i.ONE))
				areas.append(n)
	var merged := true
	while merged:   # join parts of one sprite (detached barrels, banners ...)
		merged = false
		for i in boxes.size():
			for j in range(i + 1, boxes.size()):
				if boxes[i].grow(MERGE).intersects(boxes[j]):
					boxes[i] = boxes[i].merge(boxes[j])
					boxes.remove_at(j)
					merged = true
					break
			if merged:
				break
	boxes.sort_custom(func(p: Rect2i, q: Rect2i) -> bool: return p.get_center().y < q.get_center().y)
	var ordered: Array[Rect2i] = []
	for i in range(0, boxes.size(), cols):
		var row := boxes.slice(i, i + cols)
		row.sort_custom(func(p: Rect2i, q: Rect2i) -> bool: return p.get_center().x < q.get_center().x)
		ordered.append_array(row)
	print("found ", ordered.size(), " sprites, expected ", names.size())
	DirAccess.make_dir_recursive_absolute(out_dir)
	for i in mini(ordered.size(), names.size()):
		var s := img.get_region(ordered[i])
		var k := float(max_px) / maxf(s.get_width(), s.get_height())
		s.resize(maxi(1, roundi(s.get_width() * k)), maxi(1, roundi(s.get_height() * k)), Image.INTERPOLATE_LANCZOS)
		s.save_png("%s/%s.png" % [out_dir, names[i]])
		print("  ", names[i], " ", s.get_size())
	quit()
