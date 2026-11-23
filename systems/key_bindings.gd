## Keyboard shortcuts. Only translates keys into signals; Main decides what they do.
class_name KeyBindings
extends Node

signal tower_key(kind: String)
signal building_key(kind: String)
signal ability_key(kind: String)
signal start_wave_key
signal speed_key
signal upgrade_key
signal cancel_key
signal restart_key

const TOWERS := {KEY_1: "gunner", KEY_2: "sniper", KEY_3: "frost", KEY_4: "cannon"}
const BUILDINGS := {KEY_5: "farm", KEY_6: "lumber", KEY_7: "house", KEY_8: "wall"}
const ABILITIES := {KEY_Q: "volley", KEY_W: "freeze"}


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	var k: int = event.keycode
	if TOWERS.has(k): tower_key.emit(TOWERS[k])
	elif BUILDINGS.has(k): building_key.emit(BUILDINGS[k])
	elif ABILITIES.has(k): ability_key.emit(ABILITIES[k])
	elif k == KEY_SPACE: start_wave_key.emit()
	elif k == KEY_F: speed_key.emit()
	elif k == KEY_U: upgrade_key.emit()
	elif k == KEY_ESCAPE: cancel_key.emit()
	elif k == KEY_R: restart_key.emit()
