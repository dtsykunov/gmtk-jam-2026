class_name EnemyController
extends Node

signal moves_shown

@onready var character: Character = get_parent()
@onready var move_timer: Timer = $MoveTimer

var _moves: Array[Character.Move] = []
var _index := 0


func show_round(moves: Array[Character.Move], move_show_time: float) -> void:
	move_timer.wait_time = move_show_time
	_moves = moves
	_index = 0
	_show_next()


func _show_next() -> void:
	character.apply_move(_moves[_index])
	_index += 1
	move_timer.start()


func _on_move_timer_timeout() -> void:
	if _index == _moves.size():
		moves_shown.emit()
	else:
		_show_next()
