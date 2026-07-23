extends Node


@onready var character : Character = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_down"):
		character.stance = Character.Stance.SITTING
	elif Input.is_action_just_released("move_down"):
		character.stance = Character.Stance.STANDING

	if Input.is_action_just_pressed("move_right"):
		character.arm_l = Character.ArmPose.RAISED
	elif Input.is_action_just_released("move_right"):
		character.arm_l = Character.ArmPose.LOWERED

	if Input.is_action_just_pressed("move_left"):
		character.arm_r = Character.ArmPose.RAISED
	elif Input.is_action_just_released("move_left"):
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
		character.hips_pose = Character.HipsPose.STRAIGHT
	elif Input.is_action_pressed("hips_left"):
		character.hips_pose = Character.HipsPose.LEFT
	elif Input.is_action_pressed("hips_right"):
		character.hips_pose = Character.HipsPose.RIGHT
	else:
		character.hips_pose = Character.HipsPose.STRAIGHT
