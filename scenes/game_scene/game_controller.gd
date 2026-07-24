extends Node

signal lvl_started # (lvl_info: LevelInfo)
signal lvl_finished # (lvl_info: LevelInfo)
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
var lvl_rounds: Array[Round] = []
var cur_round : Round = null

const LEVEL_0 := [10, 5.0, 1, Character.MoveDifficulty.EASY] # -> LevelInfo

# const LEVEL_0 := [10, 5.0, 1, Character.MoveDifficulty.EASY]
# const LEVEL_1 := [10, 5.0, 1, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM]
# const LEVEL_2 := [10, 5.0, 1, Character.MoveDifficulty.ALL]
# const LEVEL_3 := [10, 3.0, 1, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM]
# const LEVEL_4 := [10, 3.0, 1, Character.MoveDifficulty.ALL]
# const LEVEL_5 := [10, 1.0, 1, Character.MoveDifficulty.EASY]
# const LEVEL_6 := [10, 1.0, 1, Character.MoveDifficulty.EASY]

const LEVELS := {
	0: LEVEL_0,
	# 1: LEVEL_1,
	# 2: LEVEL_2,
	# 3: LEVEL_3,
	# 4: LEVEL_4,
	# 5: LEVEL_5,
	# 6: LEVEL_6,
}
var MAX_LEVEL : int = LEVELS.keys().max()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown_started.connect(player_controller.unpause_input)
	round_finished.connect(player_controller.pause_input)
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
			lvl_finished.emit()
			return
		setup_level()
		lvl_started.emit()

	start_round()


func _on_start_timer_timeout() -> void:
	setup_level()
	lvl_started.emit()
	start_round()


func start_round() -> void:
	cur_round = lvl_rounds.pop_back()
	round_started.emit(cur_round)
	enemy_controller.show_round(cur_round.moves)


func setup_level() -> void:
	var lvl_info : Array = LEVELS[cur_difficulty]

	var lvl_round_count : int = lvl_info[0]
	var countdown_wait_time : float = lvl_info[1]
	var round_move_count : int = lvl_info[2]
	var move_difficulty : Character.MoveDifficulty = lvl_info[3]

	countdown.wait_time = countdown_wait_time

	var next_lvl_rounds : Array[Round] = []

	for i in range(lvl_round_count):
		var round_moves := Character.randomize_moves(move_difficulty, round_move_count)
		next_lvl_rounds.append(Round.new(round_moves))

	lvl_rounds = next_lvl_rounds


func _moves_match(recorded: Array[Character.Move], round_moves: Array[Character.Move]) -> bool:
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


func _on_enemy_moves_shown() -> void:
	countdown.start()
	countdown_started.emit()
