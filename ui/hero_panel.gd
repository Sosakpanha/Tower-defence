## Bottom-left hero panel: recruit buttons, name/level/HP/XP, move toggle, evolution choices.
## Holds no rules: shows `set_info()` from HeroManager and emits signals.
class_name HeroPanel
extends CanvasLayer

signal buy_pressed(kind: String)
signal evolve_pressed(id: String)
signal move_pressed

var info := {}
var gold := 0
var panel := PanelContainer.new()
var label := Label.new()
var hp_bar := ProgressBar.new()
var buy_row := HBoxContainer.new()
var buy_buttons := {}      # hero kind -> Button
var move_btn := Button.new()
var evolve_row := HBoxContainer.new()
var evolve_buttons := {}   # evolution id -> Button (built on demand)
var _evo_kind := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.12, 0.07, 0.92)
	sb.border_color = Color(0.85, 0.65, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", sb)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 6
	panel.offset_bottom = -84   # sits above the building bar
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	label.add_theme_font_size_override("font_size", 14)
	box.add_child(label)
	hp_bar.custom_minimum_size = Vector2(0, 10)
	hp_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color.DEEP_SKY_BLUE
	hp_bar.add_theme_stylebox_override("fill", fill)
	box.add_child(hp_bar)
	buy_row.add_theme_constant_override("separation", 6)
	box.add_child(buy_row)
	for k: String in Heroes.KINDS:
		var b := Button.new()
		b.text = "Recruit %s $%d" % [Heroes.KINDS[k].name, Heroes.KINDS[k].cost]
		b.custom_minimum_size = Vector2(150, 52)
		UiStyle.style_button(b, 14)
		b.pressed.connect(buy_pressed.emit.bind(k))
		buy_row.add_child(b)
		buy_buttons[k] = b
	move_btn.custom_minimum_size = Vector2(0, 48)
	UiStyle.style_button(move_btn, 14)
	move_btn.pressed.connect(move_pressed.emit)
	box.add_child(move_btn)
	evolve_row.add_theme_constant_override("separation", 6)
	box.add_child(evolve_row)
	add_child(panel)
	set_info({"has": false})


func set_gold(g: int) -> void:
	gold = g
	_refresh()


func set_info(d: Dictionary) -> void:
	info = d
	_refresh()


func _refresh() -> void:
	var has: bool = info.get("has", false)
	var alive: bool = info.get("alive", false)
	buy_row.visible = not has
	for k: String in buy_buttons:
		buy_buttons[k].disabled = gold < Heroes.KINDS[k].cost
	label.visible = has
	hp_bar.visible = has and alive
	move_btn.visible = has and alive
	if has:
		var nk: int = info.next_kills
		label.text = "%s  Lv %d   %s" % [info.name, info.level, "MAX" if nk < 0 else "kills %d/%d" % [info.kills, nk]]
		if not alive:
			label.text += "\nDown - back in %ds (or at dawn)" % ceili(info.respawn)
		hp_bar.max_value = info.max_hp
		hp_bar.value = info.hp
		move_btn.text = "Tap map to move..." if info.selected else "Move hero (or tap it)"
	evolve_row.visible = has and info.get("evolve", false)
	if evolve_row.visible:
		_fill_evolve_row()
	panel.reset_size()


func _fill_evolve_row() -> void:
	var kind: String = info.kind
	if _evo_kind != kind:   # build the two branch buttons for this hero
		for b: Button in evolve_buttons.values():
			b.queue_free()
		evolve_buttons.clear()
		for id: String in Heroes.EVOS[kind]:
			var b := Button.new()
			var e: Dictionary = Heroes.EVOS[kind][id]
			b.text = "%s $%d\n%s" % [e.name, Heroes.EVOLVE_COST, e.desc]
			b.custom_minimum_size = Vector2(150, 62)
			UiStyle.style_button(b, 13)
			b.pressed.connect(evolve_pressed.emit.bind(id))
			evolve_row.add_child(b)
			evolve_buttons[id] = b
		_evo_kind = kind
	for b: Button in evolve_buttons.values():
		b.disabled = gold < Heroes.EVOLVE_COST
