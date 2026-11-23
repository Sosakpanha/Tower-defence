## Pulsing red "BOSS WAVE TONIGHT" pill, shown during the day before a boss wave.
class_name BossWarning
extends CanvasLayer

var label := Label.new()
var tween: Tween


func _ready() -> void:
	label.text = "!  BOSS WAVE TONIGHT  !"
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.85))
	label.add_theme_color_override("font_outline_color", Color(0.45, 0.0, 0.0))
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(Config.SCREEN.x / 2.0 - 160, 120)   # jungle strip under the preview, above the grass (y 144)
	label.size = Vector2(320, 24)
	label.pivot_offset = label.size / 2.0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = false
	add_child(label)


func set_active(on: bool) -> void:
	if tween:
		tween.kill()
	label.visible = on
	if not on:
		return
	label.scale = Vector2(1.3, 1.3)
	tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.35)
	tween.set_loops()
	tween.tween_property(label, "modulate", Color(1, 0.5, 0.5), 0.5)
	tween.tween_property(label, "modulate", Color.WHITE, 0.5)
