## Compact hero chip docked in the top bar (between the abilities and the stats): portrait,
## name/level, HP and XP bars. Tap = recruit / evolve popover, or move-toggle otherwise.
## Holds no rules: shows `set_info()` from HeroManager and emits signals.
class_name HeroPanel
extends CanvasLayer

signal buy_pressed(kind: String)
signal evolve_pressed(id: String)
signal move_pressed

const CHIP_POS := Vector2(758, 4)
const CHIP_SIZE := Vector2(178, 72)

var info := {}
var gold := 0
var chip := Button.new()
var portrait := Portrait.new()
var label := Label.new()
var badge := Label.new()
var hp_bar := Bar.new()
var xp_bar := Bar.new()
var pop := HeroPopover.new()
var _open := false
var _could_evolve := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	chip.position = CHIP_POS
	chip.custom_minimum_size = CHIP_SIZE
	chip.size = CHIP_SIZE
	UiStyle.style_button(chip, 15)
	chip.pressed.connect(_on_chip)
	add_child(chip)
	portrait.position = Vector2(14, 14)
	portrait.size = Vector2(44, 44)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(portrait)
	label.position = Vector2(64, 8)
	label.size = Vector2(106, 22)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.03))
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(label)
	hp_bar.position = Vector2(64, 34)
	xp_bar.position = Vector2(64, 48)
	_style_bar(hp_bar, Color.DEEP_SKY_BLUE, 10)
	_style_bar(xp_bar, Color(0.95, 0.8, 0.25), 7)
	badge.text = "!"
	badge.position = Vector2(CHIP_SIZE.x - 22, -6)
	badge.add_theme_font_size_override("font_size", 20)
	badge.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	badge.add_theme_color_override("font_outline_color", Color(0.4, 0.05, 0.0))
	badge.add_theme_constant_override("outline_size", 8)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(badge)
	pop.position = Vector2(CHIP_POS.x + CHIP_SIZE.x - 350, CHIP_POS.y + CHIP_SIZE.y + 6)
	pop.visible = false
	pop.buy_pressed.connect(buy_pressed.emit)
	pop.evolve_pressed.connect(evolve_pressed.emit)
	pop.closed.connect(_set_open.bind(false))
	add_child(pop)
	set_info({"has": false})


func _style_bar(b: Bar, color: Color, h: float) -> void:
	b.size = Vector2(104, h)
	b.color = color
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(b)


func set_gold(g: int) -> void:
	gold = g
	_refresh()


func set_info(d: Dictionary) -> void:
	info = d
	var can: bool = d.get("has", false) and d.get("evolve", false)
	if can and not _could_evolve:
		_open = true        # offer the choice once; the player can dismiss it
	_could_evolve = can
	if d.get("has", false) and _open and not can:
		_open = false       # recruited or evolved: done
	_refresh()


func _on_chip() -> void:
	if not info.get("has", false) or _could_evolve:
		_set_open(not _open)
	else:
		move_pressed.emit()


func _set_open(on: bool) -> void:
	_open = on
	_refresh()


func _refresh() -> void:
	var has: bool = info.get("has", false)
	var alive: bool = info.get("alive", false)
	portrait.visible = has
	hp_bar.visible = has and alive
	xp_bar.visible = has
	badge.visible = _could_evolve
	if not has:
		label.position = Vector2(0, 24)
		label.size = Vector2(CHIP_SIZE.x, 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = "+ Recruit hero"
	else:
		label.position = Vector2(64, 8)
		label.size = Vector2(106, 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var nk: int = info.next_kills
		label.text = "%s Lv%d" % [info.name, info.level] if alive else "Down %ds" % ceili(info.respawn)
		hp_bar.set_frac(info.hp / maxf(info.max_hp, 1.0))
		xp_bar.set_frac(1.0 if nk < 0 else float(info.kills) / maxf(nk, 1))
		portrait.color = Heroes.KINDS[info.kind].color
		portrait.dim = not alive
		portrait.selected = info.get("selected", false)
		portrait.queue_redraw()
		chip.tooltip_text = "Tap to move the hero, then tap the map" if alive else ""
	pop.visible = _open and pop.refresh(info, gold)


## Round colored portrait with a ring that lights up while the hero is selected for moving.
class Portrait extends Control:
	var color := Color.WHITE
	var dim := false
	var selected := false

	func _draw() -> void:
		var c := size / 2.0
		draw_circle(c, 21.0, Color(0.1, 0.06, 0.03))
		draw_circle(c, 18.0, color.darkened(0.5 if dim else 0.0))
		draw_arc(c, 21.0, 0, TAU, 32, Color(1, 0.9, 0.3) if selected else Color(0.85, 0.65, 0.3), 3.0)


## Thin filled bar (fraction 0..1) on a dark track.
class Bar extends Control:
	var color := Color.WHITE
	var frac := 0.0

	func set_frac(f: float) -> void:
		frac = clampf(f, 0.0, 1.0)
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.05, 0.03, 0.9))
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * frac, size.y)), color)
