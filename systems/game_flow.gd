## Game-session flow: speed cycling, pause, back to menu, restart, app backgrounding.
## `before_leave` fires first (menu / app backgrounded) so Main can autosave.
class_name GameFlow
extends Node

signal speed_changed(multiplier: float)
signal paused_changed(on: bool)
signal before_leave

var speed_idx := 0
var locked := false   # set when the game is over: pausing is pointless


func setup(hud: Hud, lifecycle: AppLifecycle) -> void:
	lifecycle.backgrounded.connect(func() -> void: before_leave.emit(); set_paused(true))
	paused_changed.connect(hud.show_pause)
	speed_changed.connect(hud.set_speed)
	hud.pause_pressed.connect(toggle_pause)
	hud.restart_pressed.connect(restart)
	hud.menu_pressed.connect(go_menu)
	hud.speed_pressed.connect(cycle_speed)
	hud.set_speed(1.0)


func cycle_speed() -> void:
	speed_idx = (speed_idx + 1) % Config.SPEEDS.size()
	Engine.time_scale = Config.SPEEDS[speed_idx]
	speed_changed.emit(Config.SPEEDS[speed_idx])


func set_paused(on: bool) -> void:
	if locked:
		return
	get_tree().paused = on
	paused_changed.emit(on)


func toggle_pause() -> void:
	set_paused(not get_tree().paused)


func go_menu() -> void:
	before_leave.emit()
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://menu.tscn")


func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
