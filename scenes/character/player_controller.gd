class_name PlayerController
extends Node

signal move_changed(move: Move)

@onready var character : Character = get_parent()

var _current_move: Move
var _current_hold_time := 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("sit"):
		character.stance = Character.Stance.SITTING
	else:
		character.stance = Character.Stance.STANDING

	# camera right
	if Input.is_action_pressed("right_arm_up"):
		character.arm_l = Character.ArmPose.RAISED
	else:
		character.arm_l = Character.ArmPose.LOWERED

	# camera left
	if Input.is_action_pressed("left_arm_up"):
		character.arm_r = Character.ArmPose.RAISED
	else:
		character.arm_r = Character.ArmPose.LOWERED

	if Input.is_action_pressed("head_left") and Input.is_action_pressed("head_right"):
		character.head_pose = Character.HeadPose.STRAIGHT
	elif Input.is_action_pressed("head_left"):
		character.head_pose = Character.HeadPose.LEFT
	elif Input.is_action_pressed("head_right"):
		character.head_pose = Character.HeadPose.RIGHT
	else:
		character.head_pose = Character.HeadPose.STRAIGHT

	if Input.is_action_pressed("hips_left") and Input.is_action_pressed("hips_right"):
		character.hips = Character.HipsPose.STRAIGHT
	elif Input.is_action_pressed("hips_left"):
		character.hips = Character.HipsPose.LEFT
	elif Input.is_action_pressed("hips_right"):
		character.hips = Character.HipsPose.RIGHT
	else:
		character.hips = Character.HipsPose.STRAIGHT

	var new_move := Move.new(character.stance, character.arm_l, character.arm_r, character.hips)
	if _current_move == null or not new_move.equals(_current_move):
		_current_move = new_move
		_current_hold_time = 0.0
		move_changed.emit(_current_move)
	else:
		_current_hold_time += delta


func start_turn() -> void:
	_current_move = null
	_current_hold_time = 0.0
