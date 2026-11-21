## Night darkening overlay, "Day N / Night N" banner and the day countdown text.
## Pure presentation: DayCycle's signals feed it.
class_name DayBanner
extends CanvasLayer

var overlay := ColorRect.new()
var banner := Label.new()
var timer_label := Label.new()


func _ready() -> void:
	overlay.color = Color(0.03, 0.04, 0.2, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	banner.add_theme_font_size_override("font_size", 56)
	banner.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0))
	banner.add_theme_constant_override("outline_size", 10)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.position = Vector2(0, 200)
	banner.size = Vector2(Config.SCREEN.x, 80)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.modulate.a = 0.0
	add_child(banner)
	timer_label.position = Vector2(Config.SCREEN.x - 340, Config.SCREEN.y - 44)
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 5)
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(timer_label)


func show_phase(is_night: bool, number: int) -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(overlay, "color:a", 0.45 if is_night else 0.0, 1.5)
	banner.text = ("Night %d - they come!" if is_night else "Day %d - build!") % number
	banner.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35) if is_night else Color(1.0, 0.92, 0.5))
	banner.modulate.a = 1.0
	tw.tween_property(banner, "modulate:a", 0.0, 1.0).set_delay(1.8)
	if is_night:
		timer_label.text = "Night: defend the castle"


func set_countdown(seconds: int) -> void:
	timer_label.text = "Night falls in %ds [Space: skip]" % seconds
