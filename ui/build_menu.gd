## Bottom bar with building buttons and the population readout.
## Shows what Main tells it; emits `building_chosen` when pressed.
class_name BuildMenu
extends CanvasLayer

signal building_chosen(kind: String)

var buttons := {}
var pop_label := Label.new()
var income_label := Label.new()


func _ready() -> void:
	var bar := HBoxContainer.new()
	bar.position = Vector2(12, Config.SCREEN.y - UiStyle.TOUCH_H - 4)
	bar.add_theme_constant_override("separation", 8)
	add_child(bar)
	var keys := Buildings.TYPES.keys()
	for i in keys.size():
		var k: String = keys[i]
		var t: Dictionary = Buildings.TYPES[k]
		var tip := "%s  $%d\n%s[%d] key" % [t.name, t.cost, _desc(t), i + 1 + Tower.TYPES.size()]
		var b := IconButton.new().setup(k, tip, "$%d" % t.cost)
		b.pressed.connect(building_chosen.emit.bind(k))
		bar.add_child(b)
		buttons[k] = b
	pop_label.add_theme_font_size_override("font_size", 22)
	pop_label.add_theme_color_override("font_outline_color", Color.BLACK)
	pop_label.add_theme_constant_override("outline_size", 5)
	pop_label.custom_minimum_size = Vector2(120, UiStyle.TOUCH_H)
	pop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(pop_label)
	income_label.add_theme_font_size_override("font_size", 22)
	income_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	income_label.add_theme_color_override("font_outline_color", Color.BLACK)
	income_label.add_theme_constant_override("outline_size", 5)
	income_label.custom_minimum_size = Vector2(120, UiStyle.TOUCH_H)
	income_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(income_label)


func set_pop(used: int, cap: int) -> void:
	pop_label.text = "Pop %d/%d" % [used, cap]


func set_income(per_sec: float) -> void:
	income_label.text = "+%.1f/s" % per_sec


## `kind` = building type being placed, or "" when a tower is selected.
func highlight(kind: String) -> void:
	for k in buttons:
		var st := UiStyle.pressed() if k == kind else UiStyle.normal()
		(buttons[k] as Button).add_theme_stylebox_override("normal", st)
		(buttons[k] as Button).add_theme_stylebox_override("hover", st)


static func _desc(t: Dictionary) -> String:
	var parts: Array[String] = []
	if t.income > 0:
		parts.append("+%.1f gold/s" % (float(t.income) / t.interval))
	if t.pop_use > 0:
		parts.append("uses %d pop" % t.pop_use)
	if t.pop_cap > 0:
		parts.append("+%d pop" % t.pop_cap)
	return "" if parts.is_empty() else ", ".join(parts) + "\n"
