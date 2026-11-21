## The terrain: kingdom grass, jungle border, and grid <-> world conversion.
class_name GameMap
extends Node2D

const TEX_GRASS := preload("res://assets/tiles/grass_a.png")
const TEX_GRASS_B := preload("res://assets/tiles/grass_b.png")
const TEX_TREE := preload("res://assets/art/tree.svg")


func mouse_cell() -> Vector2i:
	return Config.world_to_cell(get_local_mouse_position())


func cell_rect(c: Vector2i) -> Rect2:
	return Rect2(Config.ORIGIN + Vector2(c) * Config.TILE, Vector2(Config.TILE, Config.TILE))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Config.SCREEN), Color(0.1, 0.1, 0.12))
	draw_rect(Rect2(0, 0, Config.SCREEN.x, Config.ORIGIN.y), Color(0.2, 0.12, 0.07))
	draw_rect(Rect2(0, Config.ORIGIN.y - 4, Config.SCREEN.x, 4), Color(0.1, 0.06, 0.03))
	for x in Config.COLS:
		for y in Config.ROWS:
			var c := Vector2i(x, y)
			var r := cell_rect(c)
			if Config.is_jungle(c):
				draw_texture_rect(TEX_GRASS_B, r, false, Color(0.35, 0.6, 0.35))
				_draw_trees(c, r)
			else:
				draw_texture_rect(TEX_GRASS if (x + y) % 3 != 0 else TEX_GRASS_B, r, false)
	for s in Config.SPAWN_CELLS:  # dark openings where enemies come out of the jungle
		draw_rect(cell_rect(s).grow(-14), Color(0.05, 0.12, 0.05, 0.8))


func _draw_trees(c: Vector2i, r: Rect2) -> void:
	if c in Config.SPAWN_CELLS:
		return
	var h := (c.x * 73 + c.y * 31) % 5
	draw_texture_rect(TEX_TREE, Rect2(r.position + Vector2(h * 3 - 6, h % 2 * 6 - 4), Vector2(56, 56)), false)
