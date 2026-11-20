## The terrain: grass, the enemy path, and grid <-> world conversion.
class_name GameMap
extends Node2D

const TEX_GRASS := preload("res://assets/tiles/grass_a.png")
const TEX_STRAIGHT := preload("res://assets/tiles/path_straight.png")
const TEX_CORNER := preload("res://assets/tiles/path_corner.png")

var path_points: Array[Vector2] = []
var path_tiles := {}  # Vector2i -> true


func _ready() -> void:
	for c in Config.PATH_CELLS:
		path_points.append(Config.cell_center(c))
	for i in Config.PATH_CELLS.size() - 1:
		var a := Config.PATH_CELLS[i]
		var b := Config.PATH_CELLS[i + 1]
		var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
		var c := a
		path_tiles[c] = true
		while c != b:
			c += step
			path_tiles[c] = true


func is_path(c: Vector2i) -> bool:
	return path_tiles.has(c)


func mouse_cell() -> Vector2i:
	var p := get_local_mouse_position() - Config.ORIGIN
	return Vector2i(floori(p.x / Config.TILE), floori(p.y / Config.TILE))


func cell_rect(c: Vector2i) -> Rect2:
	return Rect2(Config.ORIGIN + Vector2(c) * Config.TILE, Vector2(Config.TILE, Config.TILE))


# path_corner.png connects West + South; path_straight.png is horizontal.
# Rotating clockwise by 90 degrees maps W->N->E->S->W.
func _draw_path_tile(c: Vector2i, r: Rect2) -> void:
	var w := is_path(c + Vector2i.LEFT)
	var e := is_path(c + Vector2i.RIGHT)
	var n := is_path(c + Vector2i.UP)
	var s := is_path(c + Vector2i.DOWN)
	var tex := TEX_STRAIGHT
	var quarter_turns := 0
	if (n or s) and not (w or e):
		quarter_turns = 1  # vertical straight
	elif (w or e) and (n or s):
		tex = TEX_CORNER
		if w and s: quarter_turns = 0
		elif w and n: quarter_turns = 1
		elif e and n: quarter_turns = 2
		else: quarter_turns = 3  # e and s
	draw_set_transform(r.get_center(), quarter_turns * PI / 2.0)
	draw_texture_rect(tex, Rect2(-r.size / 2.0, r.size), false)
	draw_set_transform(Vector2.ZERO, 0.0)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Config.SCREEN), Color(0.1, 0.1, 0.12))
	draw_rect(Rect2(0, 0, Config.SCREEN.x, Config.ORIGIN.y), Color(0.2, 0.12, 0.07))
	draw_rect(Rect2(0, Config.ORIGIN.y - 4, Config.SCREEN.x, 4), Color(0.1, 0.06, 0.03))
	for x in Config.COLS:
		for y in Config.ROWS:
			var c := Vector2i(x, y)
			if is_path(c):
				_draw_path_tile(c, cell_rect(c))
			else:
				draw_texture_rect(TEX_GRASS, cell_rect(c), false)
