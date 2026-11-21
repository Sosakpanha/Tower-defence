## Centered popup used for GAME OVER / YOU WIN / PAUSED, with touch buttons.
class_name OverlayPanel
extends Panel

signal restart_pressed
signal resume_pressed

var label := Label.new()
var resume_btn := Button.new()
var restart_btn := Button.new()


func _init() -> void:
	add_theme_stylebox_override("panel", UiStyle.make_style("res://assets/ui/panel.png", 60, 60))
	position = Vector2(390, 150)
	size = Vector2(500, 420)
	visible = false
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 60
	box.offset_right = -60
	box.offset_top = 50
	box.offset_bottom = -50
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_outline_color", Color(1, 0.95, 0.8))
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(label)
	resume_btn.text = "Resume"
	restart_btn.text = "Restart"
	for b in [resume_btn, restart_btn]:
		b.custom_minimum_size = Vector2(0, UiStyle.TOUCH_H)
		UiStyle.style_button(b, 26)
		box.add_child(b)
	resume_btn.pressed.connect(resume_pressed.emit)
	restart_btn.pressed.connect(restart_pressed.emit)


func show_overlay(text: String, good: bool, can_resume: bool) -> void:
	label.text = text
	label.add_theme_color_override("font_color", Color(0.15, 0.45, 0.1) if good else Color(0.65, 0.1, 0.08))
	resume_btn.visible = can_resume
	visible = true
