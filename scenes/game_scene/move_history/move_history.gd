class_name MoveHistory
extends VBoxContainer

@export var move_control_scene: PackedScene = preload("res://scenes/game_scene/move_control/move_control.tscn")


func push_move(move: Move) -> void:
	var entry: MoveControl = move_control_scene.instantiate()
	add_child(entry)
	entry.apply_move(move)


func pop_oldest() -> void:
	if get_child_count() == 0:
		return
	var oldest := get_child(0)
	remove_child(oldest)
	oldest.queue_free()


func clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
