extends Node

signal lvl_started(lvl_info: LevelInfo)
signal lvl_finished(lvl_info: LevelInfo)
signal round_started(round: Round)
signal round_finished(round: Round)
signal countdown_started

@export var player: Character
@export var enemy: Character
@export var player_controller: PlayerController
@export var enemy_controller: EnemyController

@onready var countdown: Timer = $Countdown
@onready var start_timer: Timer = $StartTimer

@onready var countdown_label: Label = %CountdownLabel
@onready var score_label: Label = %ScoreLabel

@onready var enemy_move_control: MoveControl = %EnemyMoveControl
@onready var player_move_control: MoveControl = %PlayerMoveControl

@onready var move_history: MoveHistory = %MoveHistory

var score := 0

var cur_difficulty := 0
var cur_level_info : LevelInfo = null
var lvl_rounds: Array[Round] = []
var cur_round : Round = null
var _player_progress := 0

static var LEVELS: Dictionary[int, LevelInfo] = {
	0: LevelInfo.new(10, 3.0, 1, Character.MoveDifficulty.EASY, .3),
	1: LevelInfo.new(10, 5.0, 1, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM, 1.0),
	2: LevelInfo.new(10, 5.0, 1, Character.MoveDifficulty.ALL, 1.0),
	3: LevelInfo.new(10, 3.0, 1, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM, 1.0),
	4: LevelInfo.new(10, 3.0, 1, Character.MoveDifficulty.ALL, 1.0),
	5: LevelInfo.new(10, 1.0, 1, Character.MoveDifficulty.EASY, 1.0),
	6: LevelInfo.new(10, 1.0, 1, Character.MoveDifficulty.EASY, 1.0),
}
var MAX_LEVEL : int = LEVELS.keys().max()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown_started.connect(player_controller.unpause_input)
	round_finished.connect(player_controller.pause_input.unbind(1))
	enemy_controller.moves_shown.connect(_on_enemy_moves_shown)

	player_controller.move_changed.connect(player_move_control.apply_move)
	player_controller.move_changed.connect(_on_player_move_changed)
	enemy_controller.move_changed.connect(_on_enemy_move_changed)

	start_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	countdown_label.text = str(ceili(countdown.time_left))


func _on_countdown_timeout() -> void:
	round_finished.emit(cur_round)

	if _moves_match(player_controller.get_recorded_moves(), cur_round.moves):
		score += 1
		score_label.text = str(score)

	if len(lvl_rounds) == 0:
		cur_difficulty += 1
		if cur_difficulty > MAX_LEVEL:
			lvl_finished.emit(cur_level_info)
			return
		setup_level()
		lvl_started.emit(cur_level_info)

	start_round()


func _on_start_timer_timeout() -> void:
	setup_level()
	lvl_started.emit(cur_level_info)
	start_round()


func start_round() -> void:
	cur_round = lvl_rounds.pop_front()
	move_history.clear()
	enemy_move_control.apply_move(null)
	_player_progress = 0
	round_started.emit(cur_round)

	var clear_enemy := true
	if len(cur_round.moves) == 1:
		clear_enemy = false
	enemy_controller.show_round(cur_round.moves, cur_round.move_show_times, clear_enemy)


func setup_level() -> void:
	cur_level_info = LEVELS[cur_difficulty]

	countdown.wait_time = cur_level_info.countdown_wait_time

	if not cur_level_info.rounds.is_empty():
		lvl_rounds = cur_level_info.rounds.duplicate()
		return

	var all_moves := Character.randomize_moves(cur_level_info.move_difficulty, cur_level_info.round_count * cur_level_info.round_move_count)

	var next_lvl_rounds : Array[Round] = []

	for i in range(cur_level_info.round_count):
		var round_moves := all_moves.slice(i * cur_level_info.round_move_count, (i + 1) * cur_level_info.round_move_count)
		var timed_moves : Array[TimedMove] = []
		for m in round_moves:
			timed_moves.append(TimedMove.new(m, cur_level_info.move_show_time))
		next_lvl_rounds.append(Round.new(timed_moves))

	lvl_rounds = next_lvl_rounds


func _moves_match(recorded: Array[Move], round_moves: Array[Move]) -> bool:
	if round_moves.size() == 1:
		if recorded.is_empty():
			return false
		return recorded.back().equals(round_moves[0])

	if recorded.size() != round_moves.size():
		return false
	for i in recorded.size():
		if not recorded[i].equals(round_moves[i]):
			return false
	return true


class TimedMove:
	var move: Move
	var show_time: float

	func _init(p_move: Move, p_show_time: float) -> void:
		move = p_move
		show_time = p_show_time


class Round:
	var moves: Array[Move]
	var move_show_times: Array[float]

	func _init(p_timed_moves: Array[TimedMove]) -> void:
		assert(len(p_timed_moves) > 0)
		moves = []
		move_show_times = []
		for timed_move in p_timed_moves:
			moves.append(timed_move.move)
			move_show_times.append(timed_move.show_time)

	static func load_from_file(path: String) -> Round:
		var file := FileAccess.open(path, FileAccess.READ)
		assert(file != null, "Could not open recording file: %s" % path)

		var timed_moves : Array[TimedMove] = []
		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			if line.is_empty():
				continue

			var parts := line.split(",")
			assert(parts.size() == 5, "Malformed recording line in %s: %s" % [path, line])
			assert(Character.Stance.has(parts[0]), "Unknown stance in %s: %s" % [path, parts[0]])
			assert(Character.ArmPose.has(parts[1]), "Unknown arm_l pose in %s: %s" % [path, parts[1]])
			assert(Character.ArmPose.has(parts[2]), "Unknown arm_r pose in %s: %s" % [path, parts[2]])
			assert(Character.HipsPose.has(parts[3]), "Unknown hips pose in %s: %s" % [path, parts[3]])

			var move := Move.new(
				Character.Stance[parts[0]],
				Character.ArmPose[parts[1]],
				Character.ArmPose[parts[2]],
				Character.HipsPose[parts[3]],
			)
			timed_moves.append(TimedMove.new(move, parts[4].to_float()))
		file.close()

		return Round.new(timed_moves)


class LevelInfo:
	var round_count: int
	var countdown_wait_time: float
	var round_move_count: int
	var move_difficulty: Character.MoveDifficulty
	var move_show_time: float
	var rounds: Array[Round]

	func _init(p_round_count: int, p_countdown_wait_time: float, p_round_move_count: int, p_move_difficulty: Character.MoveDifficulty, p_move_show_time: float, p_rounds: Array[Round] = []) -> void:
		round_count = p_round_count
		countdown_wait_time = p_countdown_wait_time
		round_move_count = p_round_move_count
		move_difficulty = p_move_difficulty
		move_show_time = p_move_show_time
		rounds = p_rounds

	static func custom(p_countdown_wait_time: float, p_rounds: Array[Round]) -> LevelInfo:
		return LevelInfo.new(0, p_countdown_wait_time, 0, Character.MoveDifficulty.EASY, 0.0, p_rounds)

	static func from_recordings(p_countdown_wait_time: float, p_recording_paths: Array[String]) -> LevelInfo:
		var loaded_rounds : Array[Round] = []
		for path in p_recording_paths:
			loaded_rounds.append(Round.load_from_file(path))
		return LevelInfo.custom(p_countdown_wait_time, loaded_rounds)


func _on_enemy_moves_shown() -> void:
	countdown.start()
	countdown_started.emit()


func _on_enemy_move_changed(move: Move) -> void:
	if enemy_move_control.move != null:
		move_history.push_move(enemy_move_control.move)
	enemy_move_control.apply_move(move)


func _on_player_move_changed(move: Move) -> void:
	if cur_round == null or cur_round.moves.size() <= 1:
		return
	if _player_progress >= cur_round.moves.size():
		return

	if move.equals(Character.DEFAULT_MOVE):
		return

	var expected := cur_round.moves[_player_progress]
	if not move.equals(expected):
		return

	move_history.pop_oldest()
	_player_progress += 1
