## Turns mouse clicks and screen taps on the map into game-level signals.
## Touch uses a two-step build (tap = preview, tap same cell again = build) so a
## stray finger never spends gold; the mouse builds on the first click.
## Taps on HUD buttons never reach here (Controls consume them first).
class_name InputRouter
extends Node

signal preview_cell(cell: Vector2i)   # (-1,-1) = clear the pending preview
signal build_requested(cell: Vector2i)
signal tower_tapped(cell: Vector2i)
signal sell_requested(cell: Vector2i)
signal ground_tapped                  # tapped outside the grid

const NONE := Vector2i(-1, -1)

var map: GameMap
var has_tower: Callable          # (Vector2i) -> bool
var pending := NONE
var enabled := true


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	# Taps arrive as mouse events emulated from touch (device == DEVICE_ID_EMULATION),
	# after the GUI had its chance to consume them.
	if event is InputEventMouseButton and event.pressed:
		handle_press(event.position, event.button_index, event.device == InputEvent.DEVICE_ID_EMULATION)


## `pos` is in viewport coordinates. Public so tests can call it directly.
func handle_press(pos: Vector2, button: int, touch: bool) -> void:
	var p := map.make_canvas_position_local(pos) - Config.ORIGIN
	var c := Vector2i(floori(p.x / Config.TILE), floori(p.y / Config.TILE))
	if not Config.in_grid(c):
		clear_pending()
		ground_tapped.emit()
		return
	if button == MOUSE_BUTTON_RIGHT:
		sell_requested.emit(c)
	elif button != MOUSE_BUTTON_LEFT:
		return
	elif has_tower.call(c):
		clear_pending()
		tower_tapped.emit(c)
	elif touch and pending != c:
		pending = c
		preview_cell.emit(c)
	else:
		clear_pending()
		build_requested.emit(c)


func clear_pending() -> void:
	if pending != NONE:
		pending = NONE
		preview_cell.emit(NONE)
