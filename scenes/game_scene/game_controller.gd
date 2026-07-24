extends Node

@export var player: Character
@export var enemy: Character

@onready var countdown: Timer = $Countdown
@onready var start_timer: Timer = $StartTimer

@onready var countdown_label: Label = %CountdownLabel
@onready var score_label: Label = %ScoreLabel

var score := 0

var cur_difficulty := 0
var cur_moves: Array[Character.Move] = []

const LEVEL_0 := [10, 5.0, Character.MoveDifficulty.EASY]
const LEVEL_1 := [10, 5.0, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM]
const LEVEL_2 := [10, 5.0, Character.MoveDifficulty.ALL]
const LEVEL_3 := [10, 3.0, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM]
const LEVEL_4 := [10, 3.0, Character.MoveDifficulty.ALL]
const LEVEL_5 := [10, 1.0, Character.MoveDifficulty.EASY]
const LEVEL_6 := [10, 1.0, Character.MoveDifficulty.EASY | Character.MoveDifficulty.MEDIUM]

const LEVELS := {
	0: LEVEL_0,
	1: LEVEL_1,
	2: LEVEL_2,
	3: LEVEL_3,
	4: LEVEL_4,
	5: LEVEL_5,
	6: LEVEL_6,
}
var MAX_LEVEL : int = LEVELS.keys().max()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	countdown_label.text = str(ceili(countdown.time_left))


func _on_countdown_timeout() -> void:
	if enemy.has_same_stance(player):
		score += 1
		score_label.text = str(score)

	if len(cur_moves) == 0:
		cur_difficulty += 1
		if cur_difficulty >= MAX_LEVEL:
			return
		setup()
	
	enemy.apply_move(cur_moves.pop_back())
	countdown.start()


func _on_start_timer_timeout() -> void:
	setup()
	enemy.apply_move(cur_moves.pop_back())
	countdown.start()


func setup() -> void:
	var diff_info : Array = LEVELS[cur_difficulty]

	var move_count : int = diff_info[0]
	var countdown_wait_time : float = diff_info[1]
	var move_difficulty : Character.MoveDifficulty = diff_info[2]

	countdown.wait_time = countdown_wait_time
	cur_moves = Character.randomize_moves(move_difficulty, move_count)
