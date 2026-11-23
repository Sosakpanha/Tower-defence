## Pure gold-rule helpers (no state): day-end bonus and building income readout.
class_name Economy
extends RefCounted


## Gold paid when wave `w` is cleared. `flawless` = the castle took no damage that night.
static func clear_bonus(w: int, flawless: bool) -> int:
	var n := Config.CLEAR_BONUS_BASE + w * Config.CLEAR_BONUS_PER_WAVE
	if flawless:
		n += Config.FLAWLESS_BONUS_BASE + w * Config.FLAWLESS_BONUS_PER_WAVE
	return n


## Gold per second produced by a set of placed buildings.
static func income_per_sec(buildings: Array) -> float:
	var total := 0.0
	for b: Building in buildings:
		if b.stats.income > 0:
			total += float(b.stats.income) / b.stats.interval
	return total
