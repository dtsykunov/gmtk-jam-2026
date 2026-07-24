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

var score := 0

var cur_difficulty := 0
var cur_level_info : LevelInfo = null
var lvl_rounds: Array[Round] = []
var cur_round : Round = null

static var LEVELS: Dictionary[int, LevelInfo] = {
	0: LevelInfo.new(10, 5.0, 1, Character.MoveDifficulty.EASY, 1.0),
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
	cur_round = lvl_rounds.pop_back()
	round_started.emit(cur_round)
	enemy_controller.show_round(cur_round.moves, cur_level_info.move_show_time)


func setup_level() -> void:
	cur_level_info = LEVELS[cur_difficulty]

	countdown.wait_time = cur_level_info.countdown_wait_time

	var next_lvl_rounds : Array[Round] = []

	for i in range(cur_level_info.round_count):
		var round_moves := Character.randomize_moves(cur_level_info.move_difficulty, cur_level_info.round_move_count)
		next_lvl_rounds.append(Round.new(round_moves))

	lvl_rounds = next_lvl_rounds


func _moves_match(recorded: Array[Character.Move], round_moves: Array[Character.Move]) -> bool:
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


class Round:
	var moves: Array[Character.Move]

	func _init(p_moves: Array[Character.Move]) -> void:
		assert(len(p_moves) > 0)
		moves = p_moves


class LevelInfo:
	var round_count: int
	var countdown_wait_time: float
	var round_move_count: int
	var move_difficulty: Character.MoveDifficulty
	var move_show_time: float

	func _init(p_round_count: int, p_countdown_wait_time: float, p_round_move_count: int, p_move_difficulty: Character.MoveDifficulty, p_move_show_time: float) -> void:
		round_count = p_round_count
		countdown_wait_time = p_countdown_wait_time
		round_move_count = p_round_move_count
		move_difficulty = p_move_difficulty
		move_show_time = p_move_show_time


func _on_enemy_moves_shown() -> void:
	countdown.start()
	countdown_started.emit()
