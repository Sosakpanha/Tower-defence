## Bottom bar with building buttons and the population readout.
## Shows what Main tells it; emits `building_chosen` when pressed.
class_name BuildMenu
extends CanvasLayer

signal building_chosen(kind: String)

var buttons := {}
var pop_label := Label.new()


func _ready() -> void:
	var bar := HBoxContainer.new()
	bar.position = Vector2(12, Config.SCREEN.y - UiStyle.TOUCH_H - 4)
	bar.add_theme_constant_override("separation", 8)
	add_child(bar)
	var keys := Buildings.TYPES.keys()
	for i in keys.size():
		var k: String = keys[i]
		var t: Dictionary = Buildings.TYPES[k]
		var tip := "%s  $%d\n[%d] key" % [t.name, t.cost, i + 1 + Tower.TYPES.size()]
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


func set_pop(used: int, cap: int) -> void:
	pop_label.text = "Pop %d/%d" % [used, cap]


## `kind` = building type being placed, or "" when a tower is selected.
func highlight(kind: String) -> void:
	for k in buttons:
		var st := UiStyle.pressed() if k == kind else UiStyle.normal()
		(buttons[k] as Button).add_theme_stylebox_override("normal", st)
		(buttons[k] as Button).add_theme_stylebox_override("hover", st)
