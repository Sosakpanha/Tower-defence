## Pure, deterministic plan for a wave: which portals it uses and what it contains.
## The day-time preview and the real spawning both read from here, so they always agree.
class_name WavePlan
extends RefCounted


static func is_boss(w: int) -> bool:
	return w > 0 and w % Config.BOSS_EVERY == 0


## Spawn cells used by wave `w` (1-2 early, more later; boss waves use at least 2).
static func portals(w: int) -> Array[Vector2i]:
	var rng := RandomNumberGenerator.new()
	rng.seed = Config.WAVE_SEED + w * 7919
	var idx: Array[int] = []
	for i in Config.SPAWN_CELLS.size():
		idx.append(i)
	for i in range(idx.size() - 1, 0, -1):  # seeded Fisher-Yates
		var j := rng.randi_range(0, i)
		var t := idx[i]
		idx[i] = idx[j]
		idx[j] = t
	var n := 1 + (w - 1) / 5 + (rng.randi_range(0, 1) if w >= 3 else 0)
	if is_boss(w):
		n = maxi(n, 2)
	n = clampi(n, 1, Config.SPAWN_CELLS.size())
	var out: Array[Vector2i] = []
	for i in n:
		out.append(Config.SPAWN_CELLS[idx[i]])
	return out


## Enemy kinds in spawn order. Boss waves: the boss first, its escort right behind it.
static func kinds(w: int) -> Array[String]:
	var base := WaveManager.wave_list(w)
	if not is_boss(w):
		return base
	var bosses: Array[String] = []
	var rest: Array[String] = []
	for k in base:
		(bosses if k == "boss" else rest).append(k)
	var out: Array[String] = bosses.duplicate()
	for i in escort_size(w) * bosses.size():
		out.append("tank" if i % 2 == 0 else "normal")
	out.append_array(rest)
	return out


static func escort_size(w: int) -> int:
	return Config.BOSS_ESCORT_BASE + w / 2 if is_boss(w) else 0


## Number of enemies at the start of the queue that all come out of the first portal together.
static func group_size(w: int) -> int:
	if not is_boss(w):
		return 0
	var b := kinds(w).count("boss")
	return b * (1 + escort_size(w))


## Portal for the `i`-th enemy (0-based) of wave `w`.
static func spawn_cell(w: int, i: int) -> Vector2i:
	var p := portals(w)
	return p[0] if i < group_size(w) else p[i % p.size()]


static func counts(w: int) -> Dictionary:
	var c := {}
	for k in kinds(w):
		c[k] = c.get(k, 0) + 1
	return c


## Extra gold when a boss wave is cleared.
static func clear_bonus(w: int) -> int:
	return Config.BOSS_BONUS_GOLD + w * 10 if is_boss(w) else 0


static func portal_name(c: Vector2i) -> String:
	if c.y == 0:
		return "North"
	if c.y == Config.ROWS - 1:
		return "South"
	return ("N" if c.y < Config.ROWS / 2 else "S") + ("W" if c.x == 0 else "E")


static func portal_names(w: int) -> Array[String]:
	var out: Array[String] = []
	for c in portals(w):
		out.append(portal_name(c))
	return out
