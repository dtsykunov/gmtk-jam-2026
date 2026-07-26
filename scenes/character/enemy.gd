class_name EnemyController
extends Node

signal moves_shown
signal move_changed(move: Move)

@onready var character: Character = get_parent()
@onready var move_timer: Timer = $MoveTimer

var _moves: Array[Move] = []
var _move_show_times: Array[float] = []
var _index := 0
var _clear := false


func show_round(moves: Array[Move], move_show_times: Array[float], clear := false) -> void:
	_moves = moves
	_move_show_times = move_show_times
	_index = 0
	_clear = clear
	_show_next()


func _show_next() -> void:
	character.apply_move(_moves[_index])
	move_changed.emit(_moves[_index])
	move_timer.wait_time = _move_show_times[_index]
	_index += 1
	move_timer.start()


func _on_move_timer_timeout() -> void:
	if _index == _moves.size():
		if _clear:
			character.apply_move(Character.DEFAULT_MOVE)
			move_changed.emit(Character.DEFAULT_MOVE)
		moves_shown.emit()
	else:
		_show_next()
