extends Node


@onready var character : Character = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("hips_down"):
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
		character.hips_pose = Character.HipsPose.STRAIGHT
	elif Input.is_action_pressed("hips_left"):
		character.hips_pose = Character.HipsPose.LEFT
	elif Input.is_action_pressed("hips_right"):
		character.hips_pose = Character.HipsPose.RIGHT
	else:
		character.hips_pose = Character.HipsPose.STRAIGHT
