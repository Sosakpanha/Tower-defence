## Game rules and input. Everything else lives in its own module:
##   core/config.gd          constants          systems/wave_manager.gd  waves + spawning
##   world/game_map.gd       terrain + grid     systems/audio.gd         sound effects
##   world/castle.gd         the castle + HP    systems/pathing.gd       enemy routes (A*)
##   world/placement_preview.gd  hover preview  ui/hud.gd                all UI
##   tower.gd / enemy.gd / projectile.gd        game objects
extends Node2D

var gold := Config.START_GOLD
var selected := "gunner"      # tower type to build
var towers := {}              # Vector2i -> Tower
var sel_cell := Vector2i(-1, -1)  # tower whose upgrade panel is open
var speed_idx := 0
var game_over := false
var won := false

var map := GameMap.new()
var castle := Castle.new()
var pathing := Pathing.new()
var preview := PlacementPreview.new()
var towers_node := Node2D.new()
var enemies_node := Node2D.new()
var projectiles_node := Node2D.new()
var sfx := Sfx.new()
var waves := WaveManager.new()
var hud := Hud.new()
var buildings := BuildingManager.new()
var build_menu := BuildMenu.new()
var day := DayCycle.new()
var day_banner := DayBanner.new()
var build_kind := ""          # building type being placed; "" = placing a tower

var lives: int:
	get: return castle.hp
var wave: int:
	get: return waves.wave
var wave_active: bool:
	get: return waves.active


func _ready() -> void:
	Engine.time_scale = 1.0
	preview.game = self
	for n in [map, castle, preview, buildings, towers_node, enemies_node, projectiles_node, sfx, waves, day, day_banner, hud, build_menu]:
		add_child(n)
	waves.setup(pathing, enemies_node)
	buildings.setup(pathing)
	day.setup(waves)
	day.phase_changed.connect(day_banner.show_phase)
	day.countdown.connect(day_banner.set_countdown)
	day.night_requested.connect(start_wave)
	buildings.income.connect(func(n: int) -> void: gold += n; _update_hud())
	buildings.changed.connect(_update_hud)
	build_menu.building_chosen.connect(_select_building)
	castle.destroyed.connect(func() -> void: _end_game(false))
	castle.damaged.connect(func(_hp: int) -> void: _update_hud())
	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_on_enemy_killed)
	waves.enemy_leaked.connect(_on_enemy_leaked)
	hud.tower_chosen.connect(_select)
	hud.start_wave_pressed.connect(start_wave)
	hud.speed_pressed.connect(cycle_speed)
	hud.upgrade_pressed.connect(upgrade_selected)
	hud.sell_pressed.connect(func() -> void: try_sell(sel_cell))
	_select(selected)
	_update_hud()


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
	elif wave >= Config.MAX_WAVE:
		hud.set_preview("")
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
			KEY_4: _select_building("farm")
			KEY_5: _select_building("lumber")
			KEY_6: _select_building("house")
			KEY_7: _select_building("wall")
			KEY_SPACE: start_wave()
			KEY_F: cycle_speed()
			KEY_U: upgrade_selected()
			KEY_ESCAPE: deselect_tower()
			KEY_R: get_tree().reload_current_scene()
	if game_over:
		return
	if event is InputEventMouseButton and event.pressed:
		var c := map.mouse_cell()
		if not Config.in_grid(c):
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if towers.has(c):
				select_tower(c)
			else:
				deselect_tower()
				try_place(c)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			try_sell(c)


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
	var t := Tower.new()
	t.setup(selected, projectiles_node)
	t.position = Config.cell_center(c)
	towers_node.add_child(t)
	towers[c] = t
	pathing.set_blocked(c, true)
	_update_hud()


func try_sell(c: Vector2i) -> void:
	if buildings.has(c):
		gold += buildings.remove(c)
		sfx.play_sfx("sell", -4.0)
		_update_hud()
		return
	if not towers.has(c):
		return
	var t: Tower = towers[c]
	gold += t.sell_value()
	sfx.play_sfx("sell", -4.0)
	if c == sel_cell:
		deselect_tower()
	t.queue_free()
	towers.erase(c)
	pathing.set_blocked(c, false)
	_update_hud()


func select_tower(c: Vector2i) -> void:
	deselect_tower()
	sel_cell = c
	towers[c].show_range = true
	towers[c].queue_redraw()
	hud.move_tower_panel(Config.cell_center(c) + Vector2(44, -40))
	_refresh_tower_panel()


func deselect_tower() -> void:
	if towers.has(sel_cell):
		var t: Tower = towers[sel_cell]
		t.show_range = false
		t.queue_redraw()
	sel_cell = Vector2i(-1, -1)
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
	gold += 20 + w * 5
	if w >= Config.MAX_WAVE:
		_end_game(true)
	_update_hud()


func _on_enemy_killed(e: Enemy) -> void:
	gold += e.reward
	_update_hud()


func _on_enemy_leaked(_e: Enemy) -> void:
	sfx.play_sfx("leak", -3.0)
	castle.take_damage(1)


func _end_game(victory: bool) -> void:
	game_over = true
	won = victory
	hud.show_message(("YOU WIN!" if victory else "GAME OVER") + "\n\nPress R to restart", victory)
	sfx.play_sfx("win" if victory else "lose")
	_update_hud()
