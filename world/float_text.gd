## Short-lived rising text such as "+5" above a building.
class_name FloatText
extends Label


static func spawn(parent: Node, pos: Vector2, text: String, color: Color = Color(1, 0.9, 0.3)) -> void:
	var f := FloatText.new()
	f.text = text
	f.position = pos - Vector2(16, 30)
	f.z_index = 50
	f.add_theme_font_size_override("font_size", 18)
	f.add_theme_color_override("font_color", color)
	f.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0))
	f.add_theme_constant_override("outline_size", 5)
	parent.add_child(f)
	var tw := f.create_tween().set_parallel(true)
	tw.tween_property(f, "position:y", f.position.y - 30.0, 1.0)
	tw.tween_property(f, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tw.chain().tween_callback(f.queue_free)
