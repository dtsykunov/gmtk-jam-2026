extends Node2D

enum Stance {
	SITTING,
	STANDING,
}

enum ArmPose {
	RAISED,
	LOWERED,
}

var arm_l := ArmPose.LOWERED
var arm_r := ArmPose.LOWERED

var stance := Stance.STANDING

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var anim_tree: AnimationTree = %AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_down"):
		stance = Stance.SITTING
		anim_tree["parameters/sit_blend/blend_amount"] = 1.0
	elif Input.is_action_just_released("move_down"):
		stance = Stance.STANDING
		anim_tree["parameters/sit_blend/blend_amount"] = 0.0

	if Input.is_action_just_pressed("move_right"):
		arm_l = ArmPose.RAISED
		anim_tree["parameters/arm_l_blend/blend_amount"] = 1.0
	elif Input.is_action_just_released("move_right"):
		arm_l = ArmPose.LOWERED
		anim_tree["parameters/arm_l_blend/blend_amount"] = 0.0

	if Input.is_action_just_pressed("move_left"):
		arm_r = ArmPose.RAISED
		anim_tree["parameters/arm_r_blend/blend_amount"] = 1.0
	elif Input.is_action_just_released("move_left"):
		arm_r = ArmPose.LOWERED
		anim_tree["parameters/arm_r_blend/blend_amount"] = 0.0
