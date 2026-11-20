## All on-screen UI. It owns no game rules: it shows what Main tells it to
## and emits signals when the player presses something.
class_name Hud
extends CanvasLayer

signal tower_chosen(kind: String)
signal start_wave_pressed
signal speed_pressed
signal upgrade_pressed
signal sell_pressed

var tower_buttons := {}
var wave_button := Button.new()
var speed_button := Button.new()
var gold_label := Label.new()
var lives_label := Label.new()
var wave_label := Label.new()
var preview_label := Label.new()
var msg_panel := Panel.new()
var msg_label := Label.new()
var tower_panel := PanelContainer.new()
var panel_label := Label.new()
var upgrade_btn := Button.new()
var sell_btn := Button.new()

var style_normal: StyleBoxTexture
var style_pressed: StyleBoxTexture


func _ready() -> void:
	style_normal = _make_style("res://assets/ui/button_normal.png", 22, 18)
	style_pressed = _make_style("res://assets/ui/button_pressed.png", 22, 18)
	_build_toolbar()
	_build_stats()
	_build_tower_panel()
	_build_message_panel()


# ---------------------------------------------------------------- Public API
func set_stats(gold: int, lives: int, wave: int) -> void:
	gold_label.text = str(gold)
	lives_label.text = str(lives)
	wave_label.text = "%d/%d" % [wave, Config.MAX_WAVE]


func set_wave_button_disabled(disabled: bool) -> void:
	wave_button.disabled = disabled


func set_speed(multiplier: float) -> void:
	speed_button.text = "Speed x%d [F]" % int(multiplier)


func set_preview(text: String) -> void:
	preview_label.text = text


func highlight_tower(kind: String) -> void:
	for key in tower_buttons:
		var tb: Button = tower_buttons[key]
		var st := style_pressed if key == kind else style_normal
		tb.add_theme_stylebox_override("normal", st)
		tb.add_theme_stylebox_override("hover", st)


func show_tower_panel(t: Tower, gold: int) -> void:
	tower_panel.visible = true
	panel_label.text = "%s  Lv %d/%d\nDmg %d  Rng %d" % [t.stats.name, t.level, Tower.MAX_LEVEL, t.get_damage(), t.get_range()]
	var cost := t.upgrade_cost()
	upgrade_btn.text = "MAX LEVEL" if cost < 0 else "Upgrade $%d [U]" % cost
	upgrade_btn.disabled = cost < 0 or gold < cost
	sell_btn.text = "Sell +$%d" % t.sell_value()
	tower_panel.reset_size()


func move_tower_panel(pos: Vector2) -> void:
	tower_panel.position = pos.clamp(Vector2(4, 84), Vector2(Config.SCREEN.x - 190, Config.SCREEN.y - 140))


func hide_tower_panel() -> void:
	tower_panel.visible = false


func show_message(text: String, victory: bool) -> void:
	msg_label.text = text
	msg_label.add_theme_color_override("font_color", Color(0.15, 0.45, 0.1) if victory else Color(0.65, 0.1, 0.08))
	msg_panel.visible = true


# ---------------------------------------------------------------- Styling
func _make_style(path: String, margin_x: float, margin_y: float) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = load(path)
	s.texture_margin_left = margin_x
	s.texture_margin_right = margin_x
	s.texture_margin_top = margin_y
	s.texture_margin_bottom = margin_y
	s.content_margin_left = margin_x
	s.content_margin_right = margin_x
	return s


func _style_button(b: Button) -> void:
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", style_normal)
	b.add_theme_stylebox_override("hover", style_normal)
	b.add_theme_stylebox_override("pressed", style_pressed)
	b.add_theme_stylebox_override("disabled", style_pressed)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color(1, 0.97, 0.88))
	b.add_theme_color_override("font_disabled_color", Color(0.75, 0.65, 0.5))
	b.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.03))
	b.add_theme_constant_override("outline_size", 5)
	b.add_theme_font_size_override("font_size", 16)


# ---------------------------------------------------------------- Building the UI
func _build_toolbar() -> void:
	var bar := HBoxContainer.new()
	bar.position = Vector2(12, 14)
	bar.add_theme_constant_override("separation", 10)
	add_child(bar)
	var keys := Tower.TYPES.keys()
	for i in keys.size():
		var k: String = keys[i]
		var t: Dictionary = Tower.TYPES[k]
		var b := Button.new()
		b.text = "[%d] %s  $%d" % [i + 1, t.name, t.cost]
		b.custom_minimum_size = Vector2(168, 56)
		b.icon = load("res://assets/ui/icons/%s.png" % k)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 30)
		_style_button(b)
		b.pressed.connect(tower_chosen.emit.bind(k))
		bar.add_child(b)
		tower_buttons[k] = b
	wave_button.text = "Start Wave [Space]"
	wave_button.custom_minimum_size = Vector2(176, 56)
	_style_button(wave_button)
	wave_button.pressed.connect(start_wave_pressed.emit)
	bar.add_child(wave_button)
	speed_button.custom_minimum_size = Vector2(110, 56)
	_style_button(speed_button)
	speed_button.pressed.connect(speed_pressed.emit)
	bar.add_child(speed_button)


func _build_stats() -> void:
	var info := HBoxContainer.new()
	info.position = Vector2(920, 20)
	info.add_theme_constant_override("separation", 6)
	add_child(info)
	for pair in [["coin", gold_label], ["heart", lives_label], ["wave_horn", wave_label]]:
		var icon := TextureRect.new()
		icon.texture = load("res://assets/ui/icons/%s.png" % pair[0])
		icon.custom_minimum_size = Vector2(36, 36)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		info.add_child(icon)
		var lbl: Label = pair[1]
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.custom_minimum_size = Vector2(54, 0)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		info.add_child(lbl)
	preview_label.position = Vector2(920, 58)
	preview_label.add_theme_font_size_override("font_size", 14)
	preview_label.add_theme_color_override("font_color", Color(1, 0.93, 0.75))
	add_child(preview_label)


func _build_tower_panel() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.12, 0.07, 0.95)
	sb.border_color = Color(0.85, 0.65, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	tower_panel.add_theme_stylebox_override("panel", sb)
	tower_panel.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	tower_panel.add_child(box)
	panel_label.add_theme_font_size_override("font_size", 16)
	box.add_child(panel_label)
	for b in [upgrade_btn, sell_btn]:
		b.custom_minimum_size = Vector2(170, 38)
		_style_button(b)
		box.add_child(b)
	upgrade_btn.pressed.connect(upgrade_pressed.emit)
	sell_btn.pressed.connect(sell_pressed.emit)
	add_child(tower_panel)


func _build_message_panel() -> void:
	msg_panel.add_theme_stylebox_override("panel", _make_style("res://assets/ui/panel.png", 60, 60))
	msg_panel.position = Vector2(390, 180)
	msg_panel.size = Vector2(500, 320)
	msg_panel.visible = false
	add_child(msg_panel)
	msg_label.add_theme_font_size_override("font_size", 40)
	msg_label.add_theme_color_override("font_outline_color", Color(1, 0.95, 0.8))
	msg_label.add_theme_constant_override("outline_size", 6)
	msg_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_panel.add_child(msg_label)
