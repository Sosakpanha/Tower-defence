## Ability buttons (top bar) with a cooldown overlay. Shows what Main/Abilities say;
## emits `ability_pressed`. Hotkeys are Q / W (handled in Main).
class_name AbilityBar
extends CanvasLayer

signal ability_pressed(kind: String)

const SIZE := 72.0
var buttons := {}
var rings := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bar := HBoxContainer.new()
	bar.position = Vector2(600, 4)
	bar.add_theme_constant_override("separation", 6)
	add_child(bar)
	var keys := ["Q", "W"]
	var i := 0
	for k in Abilities.TYPES:
		var t: Dictionary = Abilities.TYPES[k]
		var b := IconButton.new().setup(k, "%s [%s]\nCooldown %ds" % [t.name, keys[i], int(t.cooldown)], keys[i])
		b.pressed.connect(ability_pressed.emit.bind(k))
		var ring := CooldownRing.new()
		b.add_child(ring)
		bar.add_child(b)
		buttons[k] = b
		rings[k] = ring
		i += 1


func set_cooldown(kind: String, fraction: float, seconds_left: float) -> void:
	if rings.has(kind):
		rings[kind].set_state(fraction, seconds_left)


## Highlights the armed ability ("" = none).
func set_aiming(kind: String) -> void:
	for k in buttons:
		var st := UiStyle.pressed() if k == kind else UiStyle.normal()
		(buttons[k] as Button).add_theme_stylebox_override("normal", st)
		(buttons[k] as Button).add_theme_stylebox_override("hover", st)


## Dark clockwise-sweeping pie plus the seconds left; a thin gold ring when ready.
class CooldownRing extends Control:
	var frac := 0.0
	var secs := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func set_state(f: float, s: float) -> void:
		frac = f
		secs = s
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		if frac <= 0.0:
			draw_arc(c, size.x / 2.0 - 4.0, 0, TAU, 40, Color(1.0, 0.9, 0.4, 0.9), 3.0)
			return
		var pts := PackedVector2Array([c])
		var a0 := -PI / 2.0
		for i in 33:
			var a := a0 + TAU * frac * i / 32.0
			pts.append(c + Vector2(cos(a), sin(a)) * size.length())
		var clip := Rect2(Vector2.ZERO, size)
		var poly := Geometry2D.intersect_polygons(pts, PackedVector2Array([clip.position, Vector2(clip.end.x, 0), clip.end, Vector2(0, clip.end.y)]))
		for p in poly:
			draw_colored_polygon(p, Color(0, 0, 0, 0.6))
		draw_string(ThemeDB.fallback_font, Vector2(0, c.y + 8), str(ceili(secs)), HORIZONTAL_ALIGNMENT_CENTER, size.x, 24, Color.WHITE)
