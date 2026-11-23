## The two evolution choices inside the tower panel (name, cost, stat preview per branch).
## Shown only for a max-level tower that has not evolved. Emits `chosen(branch_id)`.
class_name EvolveBox
extends VBoxContainer

signal chosen(id: String)

var _buttons := {}   # branch id -> Button


func _init() -> void:
	visible = false
	add_theme_constant_override("separation", 6)


func show_for(t: Tower, gold: int) -> void:
	var branches := Evolutions.branches(t.kind)
	visible = t.evolve_cost() >= 0 and not branches.is_empty()
	if not visible:
		return
	for id: String in branches:
		if not _buttons.has(id):
			var b := Button.new()
			b.custom_minimum_size = Vector2(300, 74)
			UiStyle.style_button(b, 14)
			b.pressed.connect(chosen.emit.bind(id))
			add_child(b)
			_buttons[id] = b
		var b: Button = _buttons[id]
		b.visible = true
		b.text = "EVOLVE: %s  $%d\n%s\n%s" % [branches[id].name, t.evolve_cost(), branches[id].desc, Evolutions.preview(t, id)]
		b.disabled = gold < t.evolve_cost()
	for id: String in _buttons:   # buttons left from another tower kind
		_buttons[id].visible = branches.has(id)
