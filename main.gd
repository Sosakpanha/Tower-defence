## Game rules and input. Everything else lives in its own module (see the table in CLAUDE.md):
## Main only holds gold/flow rules, routes input and connects the modules' signals.
extends Node2D

var gold := Config.START_GOLD
var selected := "gunner"      # tower type to build
var speed_idx := 0
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
var abilities := Abilities.new()
var ability_bar := AbilityBar.new()
var aim_ring := AimRing.new()
var planner := NightPlanner.new()
var shake := ScreenShake.new()
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
	for n in [map, castle, preview, buildings, tower_mgr, enemies_node, projectiles_node, sfx, waves, day, day_banner, hud, build_menu, router, lifecycle, abilities, ability_bar, aim_ring, planner, shake]:
		add_child(n)
	tower_mgr.setup(pathing, projectiles_node)
	waves.setup(pathing, enemies_node)
	buildings.setup(pathing)
	planner.setup(day, self)    # before day.setup so it sees day 1
	day.setup(waves)
	_wire_abilities()
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
	lifecycle.backgrounded.connect(func() -> void: autosave(); set_paused(true))
	hud.pause_pressed.connect(func() -> void: set_paused(not get_tree().paused))
	hud.restart_pressed.connect(restart)
	hud.menu_pressed.connect(go_menu)
	hud.tower_chosen.connect(_select)
	hud.start_wave_pressed.connect(start_wave)
	hud.speed_pressed.connect(cycle_speed)
	hud.upgrade_pressed.connect(upgrade_selected)
	hud.sell_pressed.connect(func() -> void: try_sell(sel_cell))
	var saved := SaveGame.take_pending()
	if not saved.is_empty():
		SaveGame.restore(self, saved)
	_select(selected)
	_update_hud()


func _wire_abilities() -> void:
	abilities.waves = waves
	shake.target = self
	ability_bar.ability_pressed.connect(abilities.press)
	router.aim_tapped.connect(abilities.aim_tap)
	abilities.aim_changed.connect(func(k: String) -> void:
		router.aiming = k != ""
		ability_bar.set_aiming(k)
		aim_ring.show_for(k))
	abilities.cooldown.connect(ability_bar.set_cooldown)
	abilities.cast.connect(func(k: String, pos: Vector2, r: float) -> void: AbilityFx.play(self, k, pos, r))
	waves.boss_spawned.connect(func() -> void:
		sfx.play_sfx("boss_horn", 0.0)
		shake.shake(Config.BOSS_SHAKE, 1.2))


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
	build_menu.set_pop(buildings.pop_used(), buildings.pop_cap())
	hud.set_wave_button_disabled(wave_active or game_over)
	hud.set_speed(Config.SPEEDS[speed_idx])
	if wave_active:
		hud.set_preview("Wave %d: %s" % [wave, WaveManager.describe(wave)])
	else:
		hud.set_preview("Next: %s" % WaveManager.describe(wave + 1))
	_refresh_tower_panel()


# ---------------------------------------------------------------- Input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select("gunner")
			KEY_2: _select("sniper")
			KEY_3: _select("frost")
			KEY_4: _select("cannon")
			KEY_5: _select_building("farm")
			KEY_6: _select_building("lumber")
			KEY_7: _select_building("house")
			KEY_8: _select_building("wall")
			KEY_SPACE: start_wave()
			KEY_F: cycle_speed()
			KEY_U: upgrade_selected()
			KEY_Q: abilities.press("volley")
			KEY_W: abilities.press("freeze")
			KEY_ESCAPE: deselect_tower(); abilities.cancel_aim()
			KEY_R: restart()


# ---------------------------------------------------------------- Towers
## A cell is buildable if it is kingdom ground (not jungle/castle), free, has no enemy
## standing on it, and building there still leaves enemies a route to the castle.
func can_build(c: Vector2i) -> bool:
	if not Config.in_grid(c) or Config.is_jungle(c) or Config.is_castle(c) or towers.has(c) or buildings.has(c):
		return false
	for e in get_tree().get_nodes_in_group("enemies"):
		if Config.world_to_cell(e.position) == c:
			return false
	return not pathing.would_block(c)


func try_place(c: Vector2i) -> void:
	if not can_build(c):
		return
	var cost := selected_cost()
	if gold < cost:
		return
	if build_kind != "":
		if not buildings.can_afford_pop(build_kind):
			return
		gold -= cost
		sfx.play_sfx("place", -4.0)
		buildings.add(build_kind, c)
		return
	gold -= cost
	sfx.play_sfx("place", -4.0)
	tower_mgr.add(selected, c)
	_update_hud()


func try_sell(c: Vector2i) -> void:
	if buildings.has(c):
		gold += buildings.remove(c)
		sfx.play_sfx("sell", -4.0)
		_update_hud()
		return
	if not towers.has(c):
		return
	gold += tower_mgr.remove(c)
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


# ---------------------------------------------------------------- Game flow
func cycle_speed() -> void:
	speed_idx = (speed_idx + 1) % Config.SPEEDS.size()
	Engine.time_scale = Config.SPEEDS[speed_idx]
	_update_hud()


func start_wave() -> void:
	if game_over:
		return
	waves.start()


func _on_wave_started(_w: int) -> void:
	sfx.play_sfx("wave_start", -3.0)
	_update_hud()


func _on_wave_cleared(w: int) -> void:
	gold += 20 + w * 5 + WavePlan.clear_bonus(w)
	tower_mgr.heal_all()
	_update_hud()
	autosave()


func _on_enemy_killed(e: Enemy) -> void:
	gold += e.reward
	_update_hud()


func _on_castle_hit(damage: int) -> void:
	sfx.play_sfx("leak", -3.0)
	castle.take_damage(damage)


func set_paused(on: bool) -> void:
	if game_over:
		return
	get_tree().paused = on
	hud.show_pause(on)


## Saves only in a build phase (day), never mid-wave or after the game ended.
func autosave() -> void:
	if not game_over and not wave_active and not day.is_night:
		SaveGame.write(self)


func go_menu() -> void:
	autosave()
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://menu.tscn")


func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _end_game() -> void:
	game_over = true
	SaveGame.clear()
	router.clear_pending()
	router.enabled = false
	hud.show_message("GAME OVER\nYou survived %d waves" % wave, false)
	sfx.play_sfx("lose")
	_update_hud()
