## Game rules and input. Everything else lives in its own module (see the table in CLAUDE.md):
## Main only holds gold/flow rules, routes input and connects the modules' signals.
extends Node2D

var gold := Config.START_GOLD
var selected := "gunner"      # tower type to build
var game_over := false

var map := GameMap.new()
var castle := Castle.new()
var pathing := Pathing.new()
var preview := PlacementPreview.new()
var tower_mgr := TowerManager.new()
var enemies_node := Node2D.new()
var projectiles_node := Node2D.new()
var sfx := Sfx.new()
var waves := WaveManager.new()
var hud := Hud.new()
var router := InputRouter.new()
var lifecycle := AppLifecycle.new()
var buildings := BuildingManager.new()
var build_menu := BuildMenu.new()
var day := DayCycle.new()
var day_banner := DayBanner.new()
var hero_mgr := HeroManager.new()
var hero_panel := HeroPanel.new()
var abilities := Abilities.new()
var ability_bar := AbilityBar.new()
var aim_ring := AimRing.new()
var planner := NightPlanner.new()
var shake := ScreenShake.new()
var keys := KeyBindings.new()
var flow := GameFlow.new()
var rules := BuildRules.new()
var hero_wiring := HeroWiring.new()
var ability_wiring := AbilityWiring.new()
var _hp_at_night := Config.CASTLE_HP  # castle HP when the wave began (flawless-bonus check)
var build_kind := ""          # building type being placed; "" = placing a tower

var towers: Dictionary:
	get: return tower_mgr.towers
var sel_cell: Vector2i:
	get: return tower_mgr.sel_cell
var lives: int:
	get: return castle.hp
var wave: int:
	get: return waves.wave
var wave_active: bool:
	get: return waves.active


func _ready() -> void:
	Engine.time_scale = 1.0
	preview.game = self
	for n in [map, castle, preview, buildings, tower_mgr, enemies_node, projectiles_node, sfx, waves, day, day_banner, hud, build_menu, hero_mgr, hero_panel, router, lifecycle, abilities, ability_bar, aim_ring, planner, shake, keys, flow, rules, hero_wiring, ability_wiring]:
		add_child(n)
	hero_mgr.setup(projectiles_node, waves, day)
	hero_wiring.spent.connect(func(n: int) -> void: gold -= n; _update_hud())
	rules.setup(pathing, func() -> Dictionary: return towers, buildings)
	hero_wiring.setup(hero_mgr, hero_panel, router, func() -> int: return gold)
	hud.evolve_pressed.connect(evolve_selected)
	tower_mgr.setup(pathing, projectiles_node)
	waves.setup(pathing, enemies_node)
	buildings.setup(pathing)
	planner.setup(day, self)    # before day.setup so it sees day 1
	day.setup(waves)
	ability_wiring.setup(self, abilities, ability_bar, aim_ring, router, waves, shake, sfx)
	_wire_keys()
	day.phase_changed.connect(day_banner.show_phase)
	day.countdown.connect(day_banner.set_countdown)
	day.night_requested.connect(start_wave)
	buildings.income.connect(func(n: int) -> void: gold += n; _update_hud())
	buildings.changed.connect(_update_hud)
	build_menu.building_chosen.connect(_select_building)
	castle.destroyed.connect(_end_game)
	castle.damaged.connect(func(_hp: int) -> void: _update_hud())
	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_on_enemy_killed)
	waves.castle_hit.connect(_on_castle_hit)
	tower_mgr.lost.connect(func(_c: Vector2i) -> void: _update_hud())
	router.map = map
	router.has_tower = func(c: Vector2i) -> bool: return towers.has(c)
	router.preview_cell.connect(func(c: Vector2i) -> void: preview.pending = c)
	router.build_requested.connect(func(c: Vector2i) -> void: deselect_tower(); try_place(c))
	router.tower_tapped.connect(select_tower)
	router.sell_requested.connect(try_sell)
	router.ground_tapped.connect(deselect_tower)
	flow.setup(hud, lifecycle)
	flow.before_leave.connect(autosave)
	hud.tower_chosen.connect(_select)
	hud.start_wave_pressed.connect(start_wave)
	hud.upgrade_pressed.connect(upgrade_selected)
	hud.sell_pressed.connect(func() -> void: try_sell(sel_cell))
	var saved := SaveGame.take_pending()
	if not saved.is_empty():
		SaveGame.restore(self, saved)
	_select(selected)
	_update_hud()


func _wire_keys() -> void:
	keys.tower_key.connect(_select)
	keys.building_key.connect(_select_building)
	keys.ability_key.connect(abilities.press)
	keys.start_wave_key.connect(start_wave)
	keys.speed_key.connect(flow.cycle_speed)
	keys.upgrade_key.connect(upgrade_selected)
	keys.cancel_key.connect(func() -> void: deselect_tower(); abilities.cancel_aim())
	keys.restart_key.connect(flow.restart)


func _select(kind: String) -> void:
	selected = kind
	build_kind = ""
	hud.highlight_tower(kind)
	build_menu.highlight("")


func _select_building(kind: String) -> void:
	build_kind = kind
	build_menu.highlight(kind)


func selected_cost() -> int:
	return Buildings.TYPES[build_kind].cost if build_kind != "" else Tower.TYPES[selected].cost


func _update_hud() -> void:
	hud.set_stats(gold, lives, wave)
	hero_panel.set_gold(gold)
	build_menu.set_pop(buildings.pop_used(), buildings.pop_cap())
	build_menu.set_income(buildings.income_per_sec())
	hud.set_wave_button_disabled(wave_active or game_over)
	_refresh_tower_panel()


func try_place(c: Vector2i) -> void:
	var cost := selected_cost()
	if not rules.can_build(c) or gold < cost or (build_kind != "" and not buildings.can_afford_pop(build_kind)):
		return
	gold -= cost
	sfx.play_sfx("place", -4.0)
	if build_kind != "":
		buildings.add(build_kind, c)
	else:
		tower_mgr.add(selected, c)
	_update_hud()


func try_sell(c: Vector2i) -> void:
	if buildings.has(c):
		gold += buildings.remove(c)
	elif towers.has(c):
		gold += tower_mgr.remove(c)
	else:
		return
	sfx.play_sfx("sell", -4.0)
	_update_hud()


func select_tower(c: Vector2i) -> void:
	tower_mgr.select(c)
	hud.move_tower_panel(Config.cell_center(c) + Vector2(44, -40))
	_refresh_tower_panel()


func deselect_tower() -> void:
	tower_mgr.deselect()
	hud.hide_tower_panel()


func _refresh_tower_panel() -> void:
	if towers.has(sel_cell) and not game_over:
		hud.show_tower_panel(towers[sel_cell], gold)
	else:
		hud.hide_tower_panel()


func upgrade_selected() -> void:
	if game_over or not towers.has(sel_cell):
		return
	var t: Tower = towers[sel_cell]
	var cost := t.upgrade_cost()
	if cost < 0 or gold < cost:
		return
	gold -= cost
	t.upgrade()
	sfx.play_sfx("place", -2.0)
	_update_hud()


func evolve_selected(id: String) -> void:
	var cost := tower_mgr.evolve_cost(sel_cell, id)
	if game_over or cost < 0 or gold < cost:
		return
	gold -= cost
	tower_mgr.evolve(sel_cell, id)
	sfx.play_sfx("place", -2.0)
	_update_hud()


func start_wave() -> void:
	if game_over:
		return
	waves.start()


func _on_wave_started(_w: int) -> void:
	_hp_at_night = castle.hp
	sfx.play_sfx("wave_start", -3.0)
	_update_hud()


func _on_wave_cleared(w: int) -> void:
	var bonus := Economy.clear_bonus(w, castle.hp >= _hp_at_night) + WavePlan.clear_bonus(w)
	gold += bonus
	FloatText.spawn(self, Config.cell_center(Vector2i(Config.CASTLE_RECT.position)), "+%d" % bonus)
	tower_mgr.heal_all()
	_update_hud()
	autosave()


func _on_enemy_killed(e: Enemy) -> void:
	gold += e.reward
	_update_hud()


func _on_castle_hit(damage: int) -> void:
	sfx.play_sfx("leak", -3.0)
	castle.take_damage(damage)


## Saves only in a build phase (day), never mid-wave or after the game ended.
func autosave() -> void:
	if not game_over and not wave_active and not day.is_night:
		SaveGame.write(self)


func _end_game() -> void:
	game_over = true
	flow.locked = true
	SaveGame.clear()
	router.clear_pending()
	router.enabled = false
	hud.show_message("GAME OVER\nYou survived %d waves" % wave, false)
	sfx.play_sfx("lose")
	_update_hud()
