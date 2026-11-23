## Strip under the top bar during the day: "Night N:  [goblin] x5 [wolf] x2   from: NW, East".
## Pure presentation; NightPlanner feeds it. Ignores the mouse so it never eats map taps.
class_name WavePreview
extends CanvasLayer

var panel := PanelContainer.new()
var row := HBoxContainer.new()


func _ready() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.07, 0.04, 0.82)
	sb.border_color = Color(0.85, 0.65, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", sb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	add_child(panel)
	panel.visible = false


func show_plan(wave: int, counts: Dictionary, portal_names: Array[String], boss: bool) -> void:
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()
	_label("Night %d:" % wave, Color(1.0, 0.92, 0.5) if not boss else Color(1.0, 0.5, 0.4))
	for k in Config.KIND_NAMES:
		if not counts.has(k):
			continue
		var icon := TextureRect.new()
		icon.texture = load("res://assets/art/gen/enemy_%s.png" % k)
		icon.custom_minimum_size = Vector2(30, 30)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		_label("x%d" % counts[k], Color.WHITE)
	_label("from " + ", ".join(portal_names), Color(1.0, 0.6, 0.5))
	panel.visible = true
	panel.reset_size()
	panel.position = Vector2((Config.SCREEN.x - panel.size.x) / 2.0, 83.0)


func hide_plan() -> void:
	panel.visible = false


func _label(text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
