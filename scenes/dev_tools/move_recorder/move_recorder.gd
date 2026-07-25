extends Node2D
## Development-only tool: hold poses on the keyboard to record a round,
## then press Enter to print a Round.new([...]) literal ready to paste
## into GameController.LEVELS, and to save the round to its own file
## (one line per move: stance,arm_l,arm_r,hips,show_time) that
## GameController.LevelInfo.from_recordings() can load directly.
## Escape discards the round in progress.

const MIN_HOLD_DURATION := 0.15
const RECORDINGS_DIR := "res://scenes/dev_tools/move_recorder/recordings"

@onready var character: Character = $Character
@onready var instructions_label: Label = $CanvasLayer/Instructions
@onready var move_history: MoveHistory = %MoveHistory

var _current_move: Move = null
var _current_hold_time := 0.0
var _round_moves: Array = [] # Array of {move: Move, duration: float}
var _next_recording_number := 1


func _ready() -> void:
	character.apply_move(Character.DEFAULT_MOVE)
	DirAccess.make_dir_recursive_absolute(RECORDINGS_DIR)
	_next_recording_number = _find_next_recording_number()
	instructions_label.text = "Hold a pose to record a move (min %.2fs).\nEnter: finish round, print it, and save it to its own file\nEscape: discard round in progress\n\nEach round is saved as its own file (loadable via\nLevelInfo.from_recordings) in:\n%s" % [MIN_HOLD_DURATION, ProjectSettings.globalize_path(RECORDINGS_DIR)]


func _process(delta: float) -> void:
	_read_input()

	var new_move := Move.new(character.stance, character.arm_l, character.arm_r, character.hips)
	if _current_move == null or not new_move.equals(_current_move):
		_finalize_current_move()
		_current_move = new_move
		_current_hold_time = 0.0
	else:
		_current_hold_time += delta

	if Input.is_action_just_pressed("ui_accept"):
		_finalize_current_move()
		_finish_round()
	elif Input.is_action_just_pressed("ui_cancel"):
		_round_moves.clear()
		_current_move = null
		_current_hold_time = 0.0
		_update_move_history()
		print("--- round discarded ---")


func _read_input() -> void:
	if Input.is_action_pressed("sit"):
		character.stance = Character.Stance.SITTING
	else:
		character.stance = Character.Stance.STANDING

	if Input.is_action_pressed("right_arm_up"):
		character.arm_l = Character.ArmPose.RAISED
	else:
		character.arm_l = Character.ArmPose.LOWERED

	if Input.is_action_pressed("left_arm_up"):
		character.arm_r = Character.ArmPose.RAISED
	else:
		character.arm_r = Character.ArmPose.LOWERED

	if Input.is_action_pressed("hips_left") and Input.is_action_pressed("hips_right"):
		character.hips = Character.HipsPose.STRAIGHT
	elif Input.is_action_pressed("hips_left"):
		character.hips = Character.HipsPose.LEFT
	elif Input.is_action_pressed("hips_right"):
		character.hips = Character.HipsPose.RIGHT
	else:
		character.hips = Character.HipsPose.STRAIGHT


func _finalize_current_move() -> void:
	if _current_move == null or _current_hold_time < MIN_HOLD_DURATION:
		return
	if _current_move.equals(Character.DEFAULT_MOVE):
		return
	_round_moves.append({"move": _current_move, "duration": _current_hold_time})
	_update_move_history()


func _finish_round() -> void:
	if _round_moves.is_empty():
		print("No moves recorded, nothing to print.")
		return

	var literal_lines : Array[String] = []
	var csv_lines : Array[String] = []
	for entry in _round_moves:
		var m : Move = entry["move"]
		var d : float = entry["duration"]
		literal_lines.append("\t\tTimedMove.new(%s, %.2f)," % [_move_literal(m), d])
		csv_lines.append(_move_csv_line(m, d))

	var round_text := "\tRound.new([\n" + "\n".join(literal_lines) + "\n\t]),"
	print(round_text)

	_write_round_file("\n".join(csv_lines) + "\n")

	_round_moves.clear()
	_current_move = null
	_current_hold_time = 0.0
	_update_move_history()


func _update_move_history() -> void:
	var moves : Array[Move] = []
	for entry in _round_moves:
		moves.append(entry["move"])
	move_history.set_moves(moves)


func _move_literal(m: Move) -> String:
	return "Move.new(Character.Stance.%s, Character.ArmPose.%s, Character.ArmPose.%s, Character.HipsPose.%s)" % [
		Character.Stance.keys()[m.stance],
		Character.ArmPose.keys()[m.arm_l],
		Character.ArmPose.keys()[m.arm_r],
		Character.HipsPose.keys()[m.hips],
	]


func _move_csv_line(m: Move, duration: float) -> String:
	return "%s,%s,%s,%s,%.2f" % [
		Character.Stance.keys()[m.stance],
		Character.ArmPose.keys()[m.arm_l],
		Character.ArmPose.keys()[m.arm_r],
		Character.HipsPose.keys()[m.hips],
		duration,
	]


func _write_round_file(content: String) -> void:
	var path := "%s/%d.txt" % [RECORDINGS_DIR, _next_recording_number]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open %s for writing (error %d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(content)
	file.close()
	print("Saved to: ", ProjectSettings.globalize_path(path))
	_next_recording_number += 1


func _find_next_recording_number() -> int:
	var highest := 0
	var dir := DirAccess.open(RECORDINGS_DIR)
	if dir != null:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "txt":
				var stem := file_name.get_basename()
				if stem.is_valid_int():
					highest = maxi(highest, stem.to_int())
			file_name = dir.get_next()
		dir.list_dir_end()
	return highest + 1
