extends Node2D

@onready var player_controller : EnemyController = %PlayerEnemyController
@onready var enemy_controller : EnemyController = %EnemyController

@onready var rounds_to_show := GameController.LEVELS[5].rounds

var idx := 0
var cur_round : GameController.Round = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_player_enemy_controller_moves_shown()


func _on_player_enemy_controller_moves_shown() -> void:
	cur_round = rounds_to_show[idx]
	idx = (idx + 1) % rounds_to_show.size()

	enemy_controller.show_round(cur_round.moves, cur_round.move_show_times, true)
	player_controller.show_round(cur_round.moves, cur_round.move_show_times, true)
