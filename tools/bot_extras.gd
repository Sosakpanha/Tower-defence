## Competent-human behaviour for tools/balance_test.gd: hero, abilities, tower evolutions.
## Flags (cmdline user args): nohero (no hero and no abilities), noabil, noevo.
extends RefCounted

const EVO_PICK := {"gunner": "rapid", "sniper": "marksman", "frost": "blizzard", "cannon": "mortar"}
const HERO_KIND := "knight"
const HERO_EVO := "paladin"
const HERO_MIN_WAVE := 2   # a human buys the hero after the first waves
const HERO_RETARGET := 0.5

var m
var hero_on: bool = not "nohero" in OS.get_cmdline_user_args()
var abil_on: bool = hero_on and not "noabil" in OS.get_cmdline_user_args()
var evo_on: bool = not "noevo" in OS.get_cmdline_user_args()
var _retarget := 0.0


func _init(main: Node) -> void:
	m = main


## Spend gold on hero/evolutions whenever affordable. Returns true if something was bought.
func spend() -> bool:
	var hm: HeroManager = m.hero_mgr
	if hero_on and hm.kind == "" and m.wave >= HERO_MIN_WAVE and m.gold >= Heroes.KINDS[HERO_KIND].cost:
		_pay(hm.try_buy(HERO_KIND, m.gold))
		return true
	if hero_on and hm.can_evolve() and m.gold >= Heroes.EVOLVE_COST:
		_pay(hm.try_evolve(HERO_EVO, m.gold))
		return true
	if evo_on:
		for t: Tower in m.towers.values():
			var c: int = t.evolve_cost()
			if c > 0 and m.gold >= c:
				m.select_tower(Config.world_to_cell(t.position))
				m.evolve_selected(EVO_PICK[t.kind])
				return true
	return false


## True while the bot is saving up for the hero or its evolution (stops other purchases).
func saving() -> bool:
	if not hero_on:
		return false
	return (m.hero_mgr.kind == "" and m.wave >= HERO_MIN_WAVE) or m.hero_mgr.can_evolve()


func _pay(n: int) -> void:
	m.gold -= n
	m._update_hud()


## Per frame during a night: steer the hero to the front line, fire abilities on cooldown.
func fight(delta: float) -> void:
	var enemies: Array = m.get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	if hero_on and m.hero_mgr.alive():
		_retarget -= delta
		if _retarget <= 0.0:
			_retarget = HERO_RETARGET
			var lead: Enemy = enemies[0]
			for e: Enemy in enemies:
				if e.progress() > lead.progress():
					lead = e
			m.hero_mgr.hero.move_target = lead.position
	if not abil_on:
		return
	var a: Abilities = m.abilities
	if a.is_ready("volley"):
		var best := Vector2.INF
		var best_n := 2   # needs a cluster, like a human would wait for
		for e: Enemy in enemies:
			var n := 0
			for o: Enemy in enemies:
				if o.position.distance_to(e.position) <= 150.0:
					n += 1
			if n >= best_n or (e.kind == "boss" and best_n <= 2):
				best_n = n
				best = e.position
		if best != Vector2.INF:
			a.cast_at("volley", best)
	if a.is_ready("freeze") and (enemies.size() >= 8 or _has_boss(enemies)):
		a.cast_at("freeze", Vector2.ZERO)


func _has_boss(enemies: Array) -> bool:
	for e: Enemy in enemies:
		if e.kind == "boss":
			return true
	return false
