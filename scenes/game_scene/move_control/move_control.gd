class_name MoveControl
extends Control

@export_dir var assets_dir : String = "res://assets/kenney_input_prompts"

var move: Move = null

const KEY_ICON_FILES := {
	KEY_A: "keyboard_a.png",
	KEY_D: "keyboard_d.png",
	KEY_LEFT: "keyboard_arrow_left.png",
	KEY_RIGHT: "keyboard_arrow_right.png",
	KEY_DOWN: "keyboard_arrow_down.png",
	KEY_UP: "keyboard_arrow_up.png",
}

var _key_icons: Dictionary[Key, Texture2D] = {}

@onready var _icon_rects: Array[TextureRect] = [
	%TextureRect,
	%TextureRect2,
	%TextureRect3,
	%TextureRect4,
]


func _ready() -> void:
	_load_icons()
	apply_move(move)


func apply_move(new_move: Move) -> void:
	move = new_move

	var inputs : Array[String] = []
	if move != null:
		inputs = move.get_inputs()

	for i in _icon_rects.size():
		var texture : Texture2D = _get_icon_texture(inputs[i]) if i < inputs.size() else null
		_icon_rects[i].texture = texture
		_icon_rects[i].visible = texture != null


func _load_icons() -> void:
	for keycode: Key in KEY_ICON_FILES:
		var path := assets_dir.path_join(KEY_ICON_FILES[keycode])
		if ResourceLoader.exists(path):
			_key_icons[keycode] = load(path)


func _get_icon_texture(action: String) -> Texture2D:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var keycode : Key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
			if _key_icons.has(keycode):
				return _key_icons[keycode]
	return null
