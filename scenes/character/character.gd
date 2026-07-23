extends Node2D

@onready var anim_player: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		anim_player.play("arm_l_up")
	elif Input.is_action_just_pressed("move_right"):
		anim_player.play("arm_r_up")
	elif Input.is_action_just_released("move_left"):
		anim_player.play_backwards("arm_l_up")
	elif Input.is_action_just_released("move_right"):
		anim_player.play_backwards("arm_r_up")
	elif Input.is_action_just_pressed("move_down"):
		anim_player.play("sit")
	elif Input.is_action_just_released("move_down"):
		anim_player.play_backwards("sit")
