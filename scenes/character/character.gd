class_name Character extends Node2D

signal move_changed(new_move: Array)

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

enum MoveDifficulty {
	EASY = 1,
	MEDIUM = 2,
	HARD = 4,
	ALL = EASY | MEDIUM | HARD,
}

const DEFAULT_MOVE := [Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.STRAIGHT]

# one button pressed at most
const EASY_MOVES := [
	# stance, arm_l, arm_r, hips
	# DEFAULT_MOVE,
	[Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.STRAIGHT],

	[Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.STRAIGHT],
	[Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.STRAIGHT],
	[Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.LEFT],
	[Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.RIGHT],
]

# two buttons pressed
const MEDIUM_MOVES := [
	[Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.STRAIGHT],
	[Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.STRAIGHT],

	[Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.LEFT],
	[Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.RIGHT],

	[Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.STRAIGHT],

	[Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.LEFT],
	[Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.RIGHT],

	[Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.LEFT],
	[Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.RIGHT],
]

# three or more buttons pressed
const HARD_MOVES := [
	[Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.STRAIGHT],

	[Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.LEFT],
	[Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.RIGHT],

	[Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.LEFT],
	[Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.RIGHT],

	[Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.LEFT],
	[Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.RIGHT],

	[Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.LEFT],
	[Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.RIGHT],
]
	
const MOVES := {
	MoveDifficulty.EASY: EASY_MOVES,
	MoveDifficulty.MEDIUM: MEDIUM_MOVES,
	MoveDifficulty.HARD: HARD_MOVES,
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

var hips := HipsPose.STRAIGHT:
	set(value):
		hips = value
		match value:
			HipsPose.LEFT:
				anim_tree["parameters/stand_hips_blend/blend_amount"] = -1.0
				anim_tree["parameters/sit_hips_blend/blend_amount"] = -1.0
			HipsPose.STRAIGHT:
				anim_tree["parameters/stand_hips_blend/blend_amount"] = 0.0
				anim_tree["parameters/sit_hips_blend/blend_amount"] = 0.0
			HipsPose.RIGHT:
				anim_tree["parameters/stand_hips_blend/blend_amount"] = 1.0
				anim_tree["parameters/sit_hips_blend/blend_amount"] = 1.0

func _ready() -> void:
	apply_move(DEFAULT_MOVE)

func has_same_stance(other: Character) -> bool:
	return [arm_l, arm_r, stance, head_pose, hips] == [other.arm_l, other.arm_r, other.stance, other.head_pose, other.hips]

func randomize() -> void:
	arm_l = ArmPose.values().pick_random()
	arm_r = ArmPose.values().pick_random()
	stance = Stance.values().pick_random()
	hips = HipsPose.values().pick_random()
	# head_pose = HeadPose.values().pick_random()

static func get_pool(difficulty: int) -> Array:
	var out: Array = []
	for d: MoveDifficulty in MOVES:
		if difficulty & d:
			out.append_array(MOVES[d])
	return out


static func randomize_moves(difficulty: int, count: int, allow_repeats := false) -> Array:
	var pool := get_pool(difficulty)
	assert(not pool.is_empty(), "No moves for difficulty %d" % difficulty)

	var out: Array = []
	var last: Array = []
	for i in count:
		var move: Array = pool.pick_random()
		if not allow_repeats and pool.size() > 1:
			while move == last:
				move = pool.pick_random()
		out.append(move)
		last = move
	return out

func apply_move(poses: Array) -> void:
	# poses = [stance, arm_l, arm_r, hips]
	assert(len(poses) == 4, "Unexpected move array")
	stance = poses[0]
	arm_l = poses[1]
	arm_r = poses[2]
	hips = poses[3]
	# head_pose = poses[4]

func get_move() -> Array:
	return [stance, arm_l, arm_r, hips]
