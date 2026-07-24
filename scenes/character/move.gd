class_name Move
extends RefCounted

var stance: Character.Stance
var arm_l: Character.ArmPose
var arm_r: Character.ArmPose
var hips: Character.HipsPose


func _init(p_stance: Character.Stance, p_arm_l: Character.ArmPose, p_arm_r: Character.ArmPose, p_hips: Character.HipsPose) -> void:
	stance = p_stance
	arm_l = p_arm_l
	arm_r = p_arm_r
	hips = p_hips


func equals(other: Move) -> bool:
	return stance == other.stance and arm_l == other.arm_l and arm_r == other.arm_r and hips == other.hips


func _to_string() -> String:
	return "Move(stance=%s, arm_l=%s, arm_r=%s, hips=%s)" % [
		Character.Stance.keys()[stance],
		Character.ArmPose.keys()[arm_l],
		Character.ArmPose.keys()[arm_r],
		Character.HipsPose.keys()[hips],
	]


func get_inputs() -> Array[String]:
	var inputs: Array[String] = []

	if stance == Character.Stance.SITTING:
		inputs.append("hips_down")

	if arm_l == Character.ArmPose.RAISED:
		inputs.append("right_arm_up")

	if arm_r == Character.ArmPose.RAISED:
		inputs.append("left_arm_up")

	if hips == Character.HipsPose.LEFT:
		inputs.append("hips_left")
	elif hips == Character.HipsPose.RIGHT:
		inputs.append("hips_right")

	return inputs
