## Hero tables: two base heroes, each with two evolutions chosen at EVOLVE_LEVEL.
## Data + pure functions only. Gold costs are the late-game gold sink (medium difficulty).
class_name Heroes
extends RefCounted

const MAX_LEVEL := 5
const KILLS_FOR_LEVEL := [0, 6, 16, 32, 55]   # total kills needed to reach level 1..5
const EVOLVE_LEVEL := 3        # evolution unlocks at this level
const EVOLVE_COST := 250
const LEVEL_BONUS := 0.18      # +18% hp/damage per level above 1

# melee heroes hit in `range`, ranged ones shoot a projectile.
const KINDS := {
	"knight": {"name": "Knight", "cost": 200, "hp": 260.0, "dmg": 16.0, "rate": 0.9, "range": 58.0, "speed": 150.0, "melee": true, "color": Color(0.55, 0.65, 0.85)},
	"archer": {"name": "Archer", "cost": 200, "hp": 130.0, "dmg": 13.0, "rate": 0.65, "range": 210.0, "speed": 160.0, "melee": false, "color": Color(0.45, 0.8, 0.45)},
}

# Multipliers on the base kind (hp/dmg/rate/range/speed); extras: regen (hp/s), heal (tower hp/s
# within 150px), splash (blast radius for ranged shots).
const EVOS := {
	"knight": {
		"paladin": {"name": "Paladin", "desc": "Tanky, heals nearby towers", "hp": 1.6, "dmg": 0.9, "rate": 1.0, "regen": 5.0, "heal": 6.0, "color": Color(1.0, 0.9, 0.4)},
		"berserker": {"name": "Berserker", "desc": "Fast and brutal", "hp": 0.9, "dmg": 1.8, "rate": 0.6, "speed": 1.25, "color": Color(0.9, 0.3, 0.25)},
	},
	"archer": {
		"ranger": {"name": "Ranger", "desc": "Huge range and damage", "dmg": 1.7, "range": 1.4, "rate": 0.85, "color": Color(0.2, 0.7, 0.35)},
		"mage": {"name": "Mage", "desc": "Fireballs hit groups", "dmg": 1.4, "range": 1.1, "rate": 1.25, "splash": 85.0, "color": Color(0.7, 0.4, 0.95)},
	},
}


static func level_for_kills(kills: int) -> int:
	var lv := 1
	for i in KILLS_FOR_LEVEL.size():
		if kills >= KILLS_FOR_LEVEL[i]:
			lv = i + 1
	return lv


## Kills needed for the next level, or -1 at max level.
static func next_kills(level: int) -> int:
	return -1 if level >= MAX_LEVEL else KILLS_FOR_LEVEL[level]


static func display_name(kind: String, evo: String) -> String:
	return EVOS[kind][evo].name if evo != "" else KINDS[kind].name


## Final stats {hp, dmg, rate, range, speed, melee, color, regen, heal, splash} for the hero.
static func stats(kind: String, evo: String, level: int) -> Dictionary:
	var b: Dictionary = KINDS[kind]
	var e: Dictionary = EVOS[kind].get(evo, {})
	var lv := 1.0 + LEVEL_BONUS * (level - 1)
	return {
		"hp": b.hp * lv * e.get("hp", 1.0),
		"dmg": b.dmg * lv * e.get("dmg", 1.0),
		"rate": b.rate * e.get("rate", 1.0),
		"range": b.range * e.get("range", 1.0),
		"speed": b.speed * e.get("speed", 1.0),
		"melee": b.melee,
		"color": e.get("color", b.color),
		"regen": e.get("regen", 0.0),
		"heal": e.get("heal", 0.0),
		"splash": e.get("splash", 0.0),
	}
