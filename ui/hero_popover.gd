## Small dismissable popover under the hero chip: recruit choices (no hero) or evolution
## choices (level 3). Emits the same intents as the panel; holds no rules.
class_name HeroPopover
extends PanelContainer

signal buy_pressed(kind: String)
signal evolve_pressed(id: String)
signal closed

const BTN := Vector2(150, 64)

var title := Label.new()
var buy_row := HBoxContainer.new()
var evolve_row := HBoxContainer.new()
var buy_buttons := {}      # hero kind -> Button
var evolve_buttons := {}   # evolution id -> Button (built per hero kind)
var _evo_kind := ""


func _ready() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.12, 0.07, 0.96)
	sb.border_color = Color(0.85, 0.65, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(6)
	add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	head.add_child(title)
	var x := Button.new()
	x.text = "X"
	x.custom_minimum_size = Vector2(48, 48)
	UiStyle.style_button(x, 16)
	x.pressed.connect(closed.emit)
	head.add_child(x)
	buy_row.add_theme_constant_override("separation", 6)
	box.add_child(buy_row)
	evolve_row.add_theme_constant_override("separation", 6)
	box.add_child(evolve_row)
	for k: String in Heroes.KINDS:
		var b := Button.new()
		b.text = "%s\n$%d" % [Heroes.KINDS[k].name, Heroes.KINDS[k].cost]
		b.custom_minimum_size = BTN
		UiStyle.style_button(b, 15)
		b.pressed.connect(buy_pressed.emit.bind(k))
		buy_row.add_child(b)
		buy_buttons[k] = b


## Shows the right content; returns false when there is nothing to offer (caller hides us).
func refresh(info: Dictionary, gold: int) -> bool:
	var has: bool = info.get("has", false)
	var evo: bool = has and info.get("evolve", false)
	buy_row.visible = not has
	evolve_row.visible = evo
	title.text = "Recruit a hero" if not has else "Evolve %s" % info.name
	for k: String in buy_buttons:
		buy_buttons[k].disabled = gold < Heroes.KINDS[k].cost
	if evo:
		_fill_evolve(info.kind, gold)
	reset_size()
	return not has or evo


func _fill_evolve(kind: String, gold: int) -> void:
	if _evo_kind != kind:
		for b: Button in evolve_buttons.values():
			b.queue_free()
		evolve_buttons.clear()
		for id: String in Heroes.EVOS[kind]:
			var e: Dictionary = Heroes.EVOS[kind][id]
			var b := Button.new()
			b.text = "%s $%d\n%s" % [e.name, Heroes.EVOLVE_COST, e.desc]
			b.custom_minimum_size = Vector2(170, 72)
			UiStyle.style_button(b, 13)
			b.pressed.connect(evolve_pressed.emit.bind(id))
			evolve_row.add_child(b)
			evolve_buttons[id] = b
		_evo_kind = kind
	for b: Button in evolve_buttons.values():
		b.disabled = gold < Heroes.EVOLVE_COST
