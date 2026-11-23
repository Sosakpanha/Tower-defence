## Shared constants and tiny helpers. Reference as `Config.TILE`, etc.
class_name Config
extends RefCounted

const TILE := 64
const COLS := 20
const ROWS := 10
const ORIGIN := Vector2(0, 80)  # leave room for the HUD bar on top
const SCREEN := Vector2(1280, 720)

const START_GOLD := 300
const CASTLE_HP := 200
const TOWER_HP := 150.0           # level 1; x1.5 / x2 on upgrade
const CASTLE_DMG_FACTOR := 0.5    # castle damage per second = enemy attack x this
const SELL_REFUND := 0.7
const FIRST_DAY_SECONDS := 45.0  # build time before wave 1
const DAY_SECONDS := 30.0        # build time between later waves
const BASE_POP := 4  # population cap before any House

# Difficulty curve (see WaveManager.wave_list and Enemy.setup). Per-wave scaling of every enemy.
const ENEMY_HP_LIN := 0.45       # hp x (1 + w*LIN + w*w*QUAD)
const ENEMY_HP_QUAD := 0.025
const ENEMY_ATK_PER_WAVE := 0.08
const ENEMY_REWARD_PER_WAVE := 0.04
const WAVE_COUNT_BASE := 3       # enemies in a wave: BASE + w*LIN + w*w*QUAD
const WAVE_COUNT_LIN := 1.5
const WAVE_COUNT_QUAD := 0.08

# Day-end rewards (paid when a wave is cleared). Surviving without castle damage pays extra.
const CLEAR_BONUS_BASE := 25
const CLEAR_BONUS_PER_WAVE := 5
const FLAWLESS_BONUS_BASE := 15
const FLAWLESS_BONUS_PER_WAVE := 5

const SPEEDS := [1.0, 2.0, 3.0]
const KIND_NAMES := {"normal": "Goblin", "fast": "Wolf", "tank": "Ogre", "archer": "Archer", "swarm": "Rat", "boss": "Warlord"}

# The kingdom: a castle in the middle, jungle on the border where enemies spawn.
const CASTLE_RECT := Rect2i(9, 4, 2, 2)
const SPAWN_CELLS: Array[Vector2i] = [
	Vector2i(0, 2), Vector2i(0, 7), Vector2i(19, 2), Vector2i(19, 7),
	Vector2i(9, 0), Vector2i(10, 9),
]


static func cell_center(c: Vector2i) -> Vector2:
	return ORIGIN + Vector2(c) * TILE + Vector2(TILE, TILE) / 2.0


static func in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < COLS and c.y < ROWS


static func world_to_cell(p: Vector2) -> Vector2i:
	var q := (p - ORIGIN) / TILE
	return Vector2i(floori(q.x), floori(q.y))


static func is_jungle(c: Vector2i) -> bool:
	return c.x == 0 or c.y == 0 or c.x == COLS - 1 or c.y == ROWS - 1


static func is_castle(c: Vector2i) -> bool:
	return CASTLE_RECT.has_point(c)

# Hero (see core/heroes.gd for stats and costs).
const HERO_SPAWN_CELL := Vector2i(10, 6)   # just below the castle
const HERO_RESPAWN := 30.0                 # seconds dead (or until dawn)
const HERO_XP_RADIUS := 260.0              # kills this close to the hero give it XP

# Wave plan, boss waves and abilities (see systems/wave_plan.gd, systems/abilities.gd).
const WAVE_SEED := 20260
const BOSS_EVERY := 5
const BOSS_FIRST_WAVE := 10          # earlier milestone waves get extra ogres instead
const BOSS_ESCORT_BASE := 4         # escort minions per boss, + wave/2
const BOSS_BONUS_GOLD := 100        # +10 per wave on top, when a boss wave is cleared
const BOSS_SHAKE := 14.0

# Enemy motion / visuals
const ENEMY_CORNER_RADIUS := 26.0   # enemies cut path corners from this far away
const ENEMY_STRIDE := 15.0          # pixels walked per animation step (walk frame / squash)
# Per-kind multiplier on the stride (bigger = slower leg cycle), tuned with tools/walk_capture_test.gd
const ENEMY_STRIDE_MULT := {"normal": 1.0, "archer": 1.0, "fast": 1.5, "swarm": 1.8, "tank": 0.85, "boss": 0.55}
const FX_HIT_INTERVAL := 0.12       # min seconds between hit sparks on one enemy
const ENEMY_DEATH_TIME := 0.4
