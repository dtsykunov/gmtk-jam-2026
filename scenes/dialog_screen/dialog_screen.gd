class_name DialogScreen
extends Control

signal revealed

@onready var text : RichTextLabel = %Text
@onready var shadow : RichTextLabel = %Shadow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_text(txt: String, reveal_time_s := 1.0, end_pause_time_s := 2.0) -> void:
	text.text = txt
	shadow.text = txt
	text.visible_ratio = 0.0
	shadow.visible_ratio = 0.0

	var tween := create_tween()
	tween.tween_property(text, "visible_ratio", 1.0, reveal_time_s)
	tween.parallel().tween_property(shadow, "visible_ratio", 1.0, reveal_time_s)
	await tween.finished

	await get_tree().create_timer(end_pause_time_s).timeout
	revealed.emit()
