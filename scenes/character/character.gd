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
		match (value):
			ArmPose.LOWERED:
				anim_tree["parameters/arm_l_blend/blend_amount"] = 0.0
			ArmPose.RAISED:
				anim_tree["parameters/arm_l_blend/blend_amount"] = 1.0


var arm_r := ArmPose.LOWERED:
	set(value):
		arm_r = value
		match value:
			ArmPose.LOWERED:
				anim_tree["parameters/arm_r_blend/blend_amount"] = 0.0
			ArmPose.RAISED:
				anim_tree["parameters/arm_r_blend/blend_amount"] = 1.0

var stance := Stance.STANDING:
	set(value):
		stance = value
		match value:
			Stance.STANDING:
				anim_tree["parameters/sit_blend/blend_amount"] = 0.0
			Stance.SITTING:
				anim_tree["parameters/sit_blend/blend_amount"] = 1.0


func has_same_stance(other: Character) -> bool:
	return [arm_l, arm_r, stance] == [other.arm_l, other.arm_r, other.stance]
