## Shared UI look: textured button/panel styles and a touch-friendly button helper.
class_name UiStyle
extends RefCounted

const TOUCH_H := 72  # min button height in viewport units (~36dp on a landscape phone)

static var _normal: StyleBoxTexture
static var _pressed: StyleBoxTexture


static func make_style(path: String, margin_x: float, margin_y: float) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = load(path)
	s.texture_margin_left = margin_x
	s.texture_margin_right = margin_x
	s.texture_margin_top = margin_y
	s.texture_margin_bottom = margin_y
	s.content_margin_left = margin_x
	s.content_margin_right = margin_x
	return s


static func normal() -> StyleBoxTexture:
	if _normal == null:
		_normal = make_style("res://assets/ui/button_normal.png", 22, 18)
	return _normal


static func pressed() -> StyleBoxTexture:
	if _pressed == null:
		_pressed = make_style("res://assets/ui/button_pressed.png", 22, 18)
	return _pressed


static func style_button(b: Button, font_size: int = 18) -> void:
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", normal())
	b.add_theme_stylebox_override("hover", normal())
	b.add_theme_stylebox_override("pressed", pressed())
	b.add_theme_stylebox_override("disabled", pressed())
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color(1, 0.97, 0.88))
	b.add_theme_color_override("font_disabled_color", Color(0.75, 0.65, 0.5))
	b.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.03))
	b.add_theme_constant_override("outline_size", 5)
	b.add_theme_font_size_override("font_size", font_size)
