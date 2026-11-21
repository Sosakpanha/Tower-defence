## Square icon-only button: icon, optional small caption (cost), name shown as a hover tooltip.
class_name IconButton
extends Button

var caption := Label.new()


## `icon_name` is looked up as assets/art/icon_<name>.svg, then assets/ui/icons/<name>.png.
static func icon_for(icon_name: String) -> Texture2D:
	var svg := "res://assets/art/icon_%s.svg" % icon_name
	return load(svg if ResourceLoader.exists(svg) else "res://assets/ui/icons/%s.png" % icon_name)


func setup(icon_name: String, tip: String, cost_text := "") -> IconButton:
	icon = icon_for(icon_name)
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	tooltip_text = tip
	custom_minimum_size = Vector2(UiStyle.TOUCH_H, UiStyle.TOUCH_H)
	UiStyle.style_button(self)
	add_theme_constant_override("icon_max_width", 44)
	caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_top = -24
	caption.offset_bottom = -2
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_size_override("font_size", 16)
	caption.add_theme_color_override("font_color", Color(1, 0.95, 0.6))
	caption.add_theme_color_override("font_outline_color", Color(0.15, 0.08, 0.02))
	caption.add_theme_constant_override("outline_size", 5)
	caption.text = cost_text
	add_child(caption)
	return self
