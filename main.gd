## Game rules and input. Everything else lives in its own module:
##   core/config.gd          constants          systems/wave_manager.gd  waves + spawning
##   world/game_map.gd       terrain + grid     systems/audio.gd         sound effects
##   world/placement_preview.gd  hover preview  ui/hud.gd                all UI
##   tower.gd / enemy.gd / projectile.gd        game objects
extends Node2D

var gold := Config.START_GOLD
var lives := Config.START_LIVES
var selected := "gunner"      # tower type to build
var towers := {}              # Vector2i -> Tower
var sel_cell := Vector2i(-1, -1)  # tower whose upgrade panel is open
var speed_idx := 0
var game_over := false
var won := false

var map := GameMap.new()
var preview := PlacementPreview.new()
var towers_node := Node2D.new()
var enemies_node := Node2D.new()
var projectiles_node := Node2D.new()
var sfx := Sfx.new()
var waves := WaveManager.new()
var hud := Hud.new()

var wave: int:
	get: return waves.wave
var wave_active: bool:
	get: return waves.active


func _ready() -> void:
	Engine.time_scale = 1.0
	preview.game = self
	for n in [map, preview, towers_node, enemies_node, projectiles_node, sfx, waves, hud]:
		add_child(n)
	waves.setup(map.path_points, enemies_node)
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
	hud.highlight_tower(kind)


func _update_hud() -> void:
	hud.set_stats(gold, lives, wave)
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
func try_place(c: Vector2i) -> void:
	if map.is_path(c) or towers.has(c):
		return
	var cost: int = Tower.TYPES[selected].cost
	if gold < cost:
		return
	gold -= cost
	sfx.play_sfx("place", -4.0)
	var t := Tower.new()
	t.setup(selected, projectiles_node)
	t.position = Config.cell_center(c)
	towers_node.add_child(t)
	towers[c] = t
	_update_hud()


func try_sell(c: Vector2i) -> void:
	if not towers.has(c):
		return
	var t: Tower = towers[c]
	gold += t.sell_value()
	sfx.play_sfx("sell", -4.0)
	if c == sel_cell:
		deselect_tower()
	t.queue_free()
	towers.erase(c)
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
	lives -= 1
	sfx.play_sfx("leak", -3.0)
	_update_hud()
	if lives <= 0:
		_end_game(false)


func _end_game(victory: bool) -> void:
	game_over = true
	won = victory
	hud.show_message(("YOU WIN!" if victory else "GAME OVER") + "\n\nPress R to restart", victory)
	sfx.play_sfx("win" if victory else "lose")
	_update_hud()
