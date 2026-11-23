## Tower evolution table. At max level (3) a tower can evolve once into one of two branches.
## Data only: add a branch = one entry. Multipliers apply on top of the level-3 stats.
## Keys: dmg/range/rate (multipliers; rate < 1 = faster), slow (seconds, absolute),
## splash (absolute radius), chain (extra enemies a shot passes through), tint, scale, badge.
class_name Evolutions
extends RefCounted

const COST_FACTOR := 2.0   # evolution cost = base tower cost x this

const BRANCHES := {
	"gunner": {
		"rapid": {"name": "Rapid Ballista", "desc": "Fires twice as fast", "dmg": 1.1, "range": 1.05, "rate": 0.5, "tint": Color(1.0, 0.85, 0.5), "scale": 1.12, "badge": Color.GOLD},
		"ranger": {"name": "Piercing Ranger", "desc": "Bolts pierce 3 foes, long range", "dmg": 1.7, "range": 1.3, "rate": 0.95, "chain": 3, "tint": Color(0.7, 1.0, 0.8), "scale": 1.12, "badge": Color.SPRING_GREEN},
	},
	"cannon": {
		"mortar": {"name": "Siege Mortar", "desc": "Huge range and blast", "dmg": 1.5, "range": 1.7, "rate": 1.35, "splash": 130.0, "tint": Color(0.75, 0.8, 1.0), "scale": 1.15, "badge": Color.CORNFLOWER_BLUE},
		"fire": {"name": "Fire Cannon", "desc": "Fast, hard-hitting blasts", "dmg": 1.5, "range": 1.0, "rate": 0.65, "splash": 95.0, "tint": Color(1.0, 0.65, 0.5), "scale": 1.15, "badge": Color.ORANGE_RED},
	},
	"frost": {
		"blizzard": {"name": "Blizzard", "desc": "Area slow on every shot", "dmg": 1.3, "range": 1.1, "rate": 1.0, "splash": 120.0, "slow": 2.5, "tint": Color(0.8, 0.95, 1.0), "scale": 1.15, "badge": Color.AQUA},
		"lance": {"name": "Ice Lance", "desc": "Heavy single-target shards", "dmg": 5.0, "range": 1.35, "rate": 1.0, "slow": 2.0, "tint": Color(0.6, 0.8, 1.0), "scale": 1.1, "badge": Color.ROYAL_BLUE},
	},
	"sniper": {
		"assassin": {"name": "Assassin", "desc": "Rapid lethal shots", "dmg": 1.4, "range": 0.9, "rate": 0.5, "tint": Color(0.75, 0.7, 0.85), "scale": 1.1, "badge": Color.MEDIUM_PURPLE},
		"marksman": {"name": "Marksman", "desc": "Massive damage, huge range", "dmg": 2.6, "range": 1.4, "rate": 1.3, "tint": Color(1.0, 0.95, 0.6), "scale": 1.12, "badge": Color.YELLOW},
	},
}


static func branches(kind: String) -> Dictionary:
	return BRANCHES.get(kind, {})


static func has(kind: String, id: String) -> bool:
	return BRANCHES.get(kind, {}).has(id)


static func cost(kind: String) -> int:
	return int(Tower.TYPES[kind].cost * COST_FACTOR)


## Modifier `key` of branch `id` (default when `id` is empty or lacks the key).
static func mod(kind: String, id: String, key: String, default: Variant) -> Variant:
	return BRANCHES.get(kind, {}).get(id, {}).get(key, default)


## One-line stat preview, e.g. "Dmg 24>41  Rng 180>234  Rate 0.35>0.17s".
static func preview(t: Tower, id: String) -> String:
	var b: Dictionary = BRANCHES[t.kind][id]
	var s := "Dmg %d>%d  Rng %d>%d  Rate %.2f>%.2fs" % [t.get_damage(), t.get_damage() * b.dmg, t.get_range(), t.get_range() * b.range, t.get_rate(), t.get_rate() * b.rate]
	if b.has("chain"):
		s += "  Pierce %d" % b.chain
	if b.has("splash"):
		s += "  Blast %d" % b.splash
	return s
