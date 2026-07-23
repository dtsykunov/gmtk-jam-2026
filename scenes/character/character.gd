class_name Character extends Node2D

enum Stance {
	SITTING,
	STANDING,
}

enum ArmPose {
	RAISED,
	LOWERED,
}

enum HeadPose {
	STRAIGHT,
	LEFT,
	RIGHT,
}

enum HipsPose {
	STRAIGHT,
	LEFT,
	RIGHT,
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

var head_pose := HeadPose.STRAIGHT:
	set(value):
		head_pose = value
		match value:
			HeadPose.LEFT:
				anim_tree["parameters/head_blend/blend_amount"] = -1.0
			HeadPose.STRAIGHT:
				anim_tree["parameters/head_blend/blend_amount"] = 0.0
			HeadPose.RIGHT:
				anim_tree["parameters/head_blend/blend_amount"] = 1.0

var hip_pose := HipsPose.STRAIGHT:
	set(value):
		head_pose = value
		match value:
			HipsPose.LEFT:
				anim_tree["parameters/sit_hips_blend/blend_amount"] = -1.0
			HipsPose.STRAIGHT:
				anim_tree["parameters/sit_hips_blend/blend_amount"] = 0.0
			HipsPose.RIGHT:
				anim_tree["parameters/sit_hips_blend/blend_amount"] = 1.0


func has_same_stance(other: Character) -> bool:
	return [arm_l, arm_r, stance, head_pose] == [other.arm_l, other.arm_r, other.stance, other.head_pose]

func randomize() -> void:
	arm_l = ArmPose.values().pick_random()
	arm_r = ArmPose.values().pick_random()
	stance = Stance.values().pick_random()
	head_pose = HeadPose.values().pick_random()
