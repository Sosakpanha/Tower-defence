## Title screen: New Game / Continue. Hands a loaded save to Main through SaveGame.pending.
class_name MainMenu
extends Control

const GAME := "res://main.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/grass_a.svg")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.55, 0.75, 0.55)
	add_child(bg)
	var castle := TextureRect.new()
	castle.texture = load("res://assets/art/gen/castle.png")
	castle.position = Vector2(Config.SCREEN.x / 2 - 110, 40)
	castle.size = Vector2(220, 220)
	castle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(castle)
	add_child(_label("KINGDOM DEFENCE", 64, Vector2(0, 260), Vector2(Config.SCREEN.x, 80)))
	add_child(_label("Hold the castle against the jungle", 22, Vector2(0, 336), Vector2(Config.SCREEN.x, 30)))
	var box := VBoxContainer.new()
	box.position = Vector2(Config.SCREEN.x / 2 - 170, 400)
	box.size = Vector2(340, 0)
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	box.add_child(_button("New Game", _new_game))
	var cont := _button("Continue\n" + SaveGame.summary() if SaveGame.has_save() else "Continue", _continue)
	cont.disabled = not SaveGame.has_save()
	box.add_child(cont)


func _label(text: String, size: int, pos: Vector2, sz: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = sz
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0.12, 0.07, 0.02))
	l.add_theme_constant_override("outline_size", maxi(4, size / 6))
	return l


func _button(text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, UiStyle.TOUCH_H + 16)
	UiStyle.style_button(b, 26)
	b.pressed.connect(on_press)
	return b


func _new_game() -> void:
	SaveGame.pending = {}
	get_tree().change_scene_to_file(GAME)


func _continue() -> void:
	SaveGame.pending = SaveGame.read()
	get_tree().change_scene_to_file(GAME)
