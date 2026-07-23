class_name Character extends Node2D

enum Stance {
	SITTING,
	STANDING,
}

enum ArmPose {
	RAISED,
	LOWERED,
}

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var anim_tree: AnimationTree = %AnimationTree

var arm_l := ArmPose.LOWERED:
	set(value):
		arm_l = value
		if value == ArmPose.LOWERED:
			anim_tree["parameters/arm_l_blend/blend_amount"] = 0.0
		elif value == ArmPose.RAISED:
			anim_tree["parameters/arm_l_blend/blend_amount"] = 1.0


var arm_r := ArmPose.LOWERED:
	set(value):
		arm_r = value
		if value == ArmPose.LOWERED:
			anim_tree["parameters/arm_r_blend/blend_amount"] = 0.0
		elif value == ArmPose.RAISED:
			anim_tree["parameters/arm_r_blend/blend_amount"] = 1.0

var stance := Stance.STANDING:
	set(value):
		stance = value
		if value == Stance.STANDING:
			anim_tree["parameters/sit_blend/blend_amount"] = 0.0
		elif value == Stance.SITTING:
			anim_tree["parameters/sit_blend/blend_amount"] = 1.0
