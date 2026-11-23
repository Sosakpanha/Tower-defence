## Owns the player's hero: buying, levelling by kills, evolving, dying/respawning, tap-to-move.
## Main only passes gold in/out (try_* return the gold spent, 0 = refused). UI reads `info()`.
class_name HeroManager
extends Node

signal changed   # anything the hero panel shows changed

var kind := ""            # "" = no hero bought yet
var evo := ""
var level := 1
var kills := 0
var respawn_left := 0.0   # >0 while dead
var hero: Hero
var projectiles: Node
var _last_sec := -1


func setup(projectile_parent: Node, waves: WaveManager, day: DayCycle) -> void:
	projectiles = projectile_parent
	waves.enemy_killed.connect(on_enemy_killed)
	day.phase_changed.connect(func(is_night: bool, _n: int) -> void:
		if not is_night:
			dawn())


func alive() -> bool:
	return is_instance_valid(hero)


func try_buy(k: String, gold: int) -> int:
	var cost: int = Heroes.KINDS[k].cost
	if kind != "" or gold < cost:
		return 0
	kind = k
	level = 1
	kills = 0
	_spawn()
	return cost


func can_evolve() -> bool:
	return kind != "" and evo == "" and level >= Heroes.EVOLVE_LEVEL


func try_evolve(id: String, gold: int) -> int:
	if not can_evolve() or not Heroes.EVOS[kind].has(id) or gold < Heroes.EVOLVE_COST:
		return 0
	evo = id
	if alive():
		hero.apply(evo, level, true)
	changed.emit()
	return Heroes.EVOLVE_COST


func on_enemy_killed(e: Enemy) -> void:
	if not alive() or e.position.distance_to(hero.position) > Config.HERO_XP_RADIUS:
		return
	kills += 1
	var lv := Heroes.level_for_kills(kills)
	if lv > level:
		level = lv
		hero.apply(evo, level)
		FloatText.spawn(get_parent(), hero.position + Vector2(0, -40), "LEVEL %d" % level, Color.GOLD)
	changed.emit()


## Dawn: a dead hero returns at once and a living one is healed.
func dawn() -> void:
	if kind == "":
		return
	if alive():
		hero.hp = hero.max_hp
	else:
		_spawn()
	changed.emit()


func toggle_select() -> void:
	if alive():
		hero.selected = not hero.selected
		hero.move_target = Vector2.INF
		changed.emit()


## Input hook (InputRouter.intercept): tap the hero to select, then tap the map to move.
## Returns true when the press was used and must not reach the build logic.
func intercept(world: Vector2, button: int) -> bool:
	if not alive():
		return false
	if button == MOUSE_BUTTON_RIGHT:
		if hero.selected:
			toggle_select()
			return true
		return false
	if button != MOUSE_BUTTON_LEFT:
		return false
	if world.distance_to(hero.position) <= Hero.HIT_RADIUS:
		toggle_select()
		return true
	if hero.selected:
		hero.move_target = world
		hero.selected = false
		changed.emit()
		return true
	return false


func _spawn() -> void:
	hero = Hero.new()
	hero.setup(kind, projectiles)
	hero.position = Config.cell_center(Config.HERO_SPAWN_CELL)
	hero.apply(evo, level, true)
	hero.died.connect(_on_died)
	hero.damaged.connect(func() -> void: changed.emit())
	respawn_left = 0.0
	add_child(hero)
	changed.emit()


func _on_died() -> void:
	hero.queue_free()
	hero = null
	respawn_left = Config.HERO_RESPAWN
	_last_sec = -1
	changed.emit()


func _process(delta: float) -> void:
	if kind == "" or alive() or respawn_left <= 0.0:
		return
	respawn_left -= delta
	if respawn_left <= 0.0:
		_spawn()
	elif ceili(respawn_left) != _last_sec:
		_last_sec = ceili(respawn_left)
		changed.emit()


## Everything the hero panel needs to draw itself.
func info() -> Dictionary:
	var d := {"has": kind != "", "kind": kind,"alive": alive(), "level": level, "kills": kills, "respawn": respawn_left,
		"selected": alive() and hero.selected, "evolve": can_evolve(), "next_kills": Heroes.next_kills(level)}
	if kind != "":
		d["name"] = Heroes.display_name(kind, evo)
		d["hp"] = hero.hp if alive() else 0.0
		d["max_hp"] = hero.max_hp if alive() else Heroes.stats(kind, evo, level).hp
	return d


func save_data() -> Dictionary:
	return {"kind": kind, "evo": evo, "level": level, "kills": kills}


func load_data(d: Dictionary) -> void:
	if d.get("kind", "") == "" or not Heroes.KINDS.has(d.kind):
		return
	kind = d.kind
	evo = d.evo if Heroes.EVOS[kind].has(d.evo) else ""
	level = clampi(int(d.level), 1, Heroes.MAX_LEVEL)
	kills = int(d.kills)
	_spawn()
