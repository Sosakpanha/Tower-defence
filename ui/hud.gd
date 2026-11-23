## All on-screen UI. It owns no game rules: it shows what Main tells it to
## and emits signals when the player presses something.
class_name Hud
extends CanvasLayer

signal tower_chosen(kind: String)
signal start_wave_pressed
signal speed_pressed
signal upgrade_pressed
signal sell_pressed
signal evolve_pressed(id: String)
signal pause_pressed
signal restart_pressed
signal menu_pressed

var tower_buttons := {}
var wave_button := IconButton.new()
var speed_button := IconButton.new()
var pause_button := IconButton.new()
var gold_label := Label.new()
var lives_label := Label.new()
var wave_label := Label.new()
var overlay := OverlayPanel.new()
var tower_panel := PanelContainer.new()
var panel_label := Label.new()
var upgrade_btn := Button.new()
var sell_btn := Button.new()
var evolve_box := EvolveBox.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # buttons keep working while the game is paused
	_build_toolbar()
	_build_stats()
	_build_tower_panel()
	_build_message_panel()


# ---------------------------------------------------------------- Public API
func set_stats(gold: int, lives: int, wave: int) -> void:
	gold_label.text = str(gold)
	lives_label.text = str(lives)
	wave_label.text = "Wave %d" % wave


func set_wave_button_disabled(disabled: bool) -> void:
	wave_button.disabled = disabled


func set_speed(multiplier: float) -> void:
	speed_button.caption.text = "x%d" % int(multiplier)


func highlight_tower(kind: String) -> void:
	for key in tower_buttons:
		var tb: Button = tower_buttons[key]
		var st := UiStyle.pressed() if key == kind else UiStyle.normal()
		tb.add_theme_stylebox_override("normal", st)
		tb.add_theme_stylebox_override("hover", st)


func show_tower_panel(t: Tower, gold: int) -> void:
	tower_panel.visible = true
	var title: String = t.stats.name if t.evo == "" else Evolutions.branches(t.kind)[t.evo].name
	panel_label.text = "%s  Lv %d/%d\nDmg %d  Rng %d" % [title, t.level, Tower.MAX_LEVEL, t.get_damage(), t.get_range()]
	var cost := t.upgrade_cost()
	upgrade_btn.visible = t.evolve_cost() < 0 and t.evo == ""   # hidden once max level (evolve choices take over)
	upgrade_btn.text = "Upgrade $%d" % cost
	upgrade_btn.disabled = cost < 0 or gold < cost
	evolve_box.show_for(t, gold)
	sell_btn.text = "Sell +$%d" % t.sell_value()
	tower_panel.reset_size()


func move_tower_panel(pos: Vector2) -> void:
	tower_panel.position = pos.clamp(Vector2(4, 84), Vector2(Config.SCREEN.x - 330, Config.SCREEN.y - 330))


func hide_tower_panel() -> void:
	tower_panel.visible = false


func show_message(text: String, victory: bool) -> void:
	overlay.show_overlay(text, victory, false)


func show_pause(paused: bool) -> void:
	if paused:
		overlay.show_overlay("PAUSED", true, true)
	else:
		overlay.visible = false
	pause_button.icon = IconButton.icon_for("play" if paused else "pause")


# ---------------------------------------------------------------- Building the UI
func _build_toolbar() -> void:
	var bar := HBoxContainer.new()
	bar.position = Vector2(6, 4)
	bar.add_theme_constant_override("separation", 6)
	add_child(bar)
	var keys := Tower.TYPES.keys()
	for k in keys:
		var t: Dictionary = Tower.TYPES[k]
		var b := IconButton.new().setup(k, "%s  $%d\n[%d] key" % [t.name, t.cost, keys.find(k) + 1], "$%d" % t.cost)
		b.pressed.connect(tower_chosen.emit.bind(k))
		bar.add_child(b)
		tower_buttons[k] = b
	_add_action(bar, wave_button, "horn", "Start wave now [Space]", start_wave_pressed)
	_add_action(bar, speed_button, "speed", "Game speed [F]", speed_pressed)
	_add_action(bar, pause_button, "pause", "Pause", pause_pressed)


func _add_action(bar: Control, b: IconButton, icon_name: String, tip: String, sig: Signal) -> void:
	b.setup(icon_name, tip)
	b.pressed.connect(sig.emit)
	bar.add_child(b)


func _build_stats() -> void:
	var info := HBoxContainer.new()
	info.position = Vector2(940, 14)
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
		lbl.custom_minimum_size = Vector2(54 if lbl != wave_label else 100, 0)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		info.add_child(lbl)


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
	panel_label.add_theme_font_size_override("font_size", 14)
	box.add_child(panel_label)
	for b in [upgrade_btn, sell_btn]:
		b.custom_minimum_size = Vector2(200, 64)
		UiStyle.style_button(b)
		box.add_child(b)
	box.add_child(evolve_box)
	evolve_box.chosen.connect(evolve_pressed.emit)
	upgrade_btn.pressed.connect(upgrade_pressed.emit)
	sell_btn.pressed.connect(sell_pressed.emit)
	add_child(tower_panel)


func _build_message_panel() -> void:
	overlay.resume_pressed.connect(pause_pressed.emit)
	overlay.restart_pressed.connect(restart_pressed.emit)
	overlay.menu_pressed.connect(menu_pressed.emit)
	add_child(overlay)
