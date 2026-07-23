extends Node

@export var player: Character
@export var enemy: Character

@onready var countdown: Timer = $Countdown

@onready var countdown_label: Label = %CountdownLabel
@onready var score_label: Label = %ScoreLabel

var score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	countdown_label.text = str(ceili(countdown.time_left))


func _on_countdown_timeout() -> void:
	if enemy.has_same_stance(player):
		score += 1
		score_label.text = str(score)

	countdown.start()
	enemy.randomize()
