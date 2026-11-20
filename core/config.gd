## Shared constants and tiny helpers. Reference as `Config.TILE`, etc.
class_name Config
extends RefCounted

const TILE := 64
const COLS := 20
const ROWS := 10
const ORIGIN := Vector2(0, 80)  # leave room for the HUD bar on top
const SCREEN := Vector2(1280, 720)

const START_GOLD := 120
const START_LIVES := 20
const MAX_WAVE := 10
const SELL_REFUND := 0.7

const SPEEDS := [1.0, 2.0, 3.0]
const KIND_NAMES := {"normal": "Goblin", "fast": "Wolf", "tank": "Ogre"}

# Path corners in grid cells; enemies walk through these in order.
const PATH_CELLS: Array[Vector2i] = [
	Vector2i(0, 2), Vector2i(4, 2), Vector2i(4, 7), Vector2i(9, 7),
	Vector2i(9, 2), Vector2i(14, 2), Vector2i(14, 7), Vector2i(19, 7),
]


static func cell_center(c: Vector2i) -> Vector2:
	return ORIGIN + Vector2(c) * TILE + Vector2(TILE, TILE) / 2.0


static func in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < COLS and c.y < ROWS
