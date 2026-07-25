class_name MoveHistory
extends VBoxContainer

@export var move_control_scene: PackedScene = preload("res://scenes/game_scene/move_control/move_control.tscn")


func set_moves(moves: Array[Move]) -> void:
	_clear()
	for move in moves:
		var entry: MoveControl = move_control_scene.instantiate()
		add_child(entry)
		entry.apply_move(move)


func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
