class_name Character extends Node2D

signal move_changed(new_move: Move)

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

static var DEFAULT_MOVE := Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.STRAIGHT)

# one button pressed at most
static var EASY_MOVES: Array[Move] = [
	# stance, arm_l, arm_r, hips
	# DEFAULT_MOVE,
	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.STRAIGHT),

	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.STRAIGHT),
	Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.STRAIGHT),
	Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.LEFT),
	Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.RIGHT),
]

# two buttons pressed
static var MEDIUM_MOVES: Array[Move] = [
	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.STRAIGHT),
	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.STRAIGHT),

	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.LEFT),
	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.LOWERED, HipsPose.RIGHT),

	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.STRAIGHT),

	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.LEFT),
	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.RIGHT),

	Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.LEFT),
	Move.new(Stance.STANDING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.RIGHT),
]

# three or more buttons pressed
static var HARD_MOVES: Array[Move] = [
	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.STRAIGHT),

	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.LEFT),
	Move.new(Stance.SITTING, ArmPose.LOWERED, ArmPose.RAISED, HipsPose.RIGHT),

	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.LEFT),
	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.LOWERED, HipsPose.RIGHT),

	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.LEFT),
	Move.new(Stance.STANDING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.RIGHT),

	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.LEFT),
	Move.new(Stance.SITTING, ArmPose.RAISED, ArmPose.RAISED, HipsPose.RIGHT),
]

static var MOVES: Dictionary[MoveDifficulty, Array] = {
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

func randomize() -> void:
	arm_l = ArmPose.values().pick_random()
	arm_r = ArmPose.values().pick_random()
	stance = Stance.values().pick_random()
	hips = HipsPose.values().pick_random()
	# head_pose = HeadPose.values().pick_random()

static func get_pool(difficulty: int) -> Array[Move]:
	var out: Array[Move] = []
	for d: MoveDifficulty in MOVES:
		if difficulty & d:
			out.append_array(MOVES[d])
	return out


static func randomize_moves(difficulty: int, count: int, allow_repeats := false) -> Array[Move]:
	var pool := get_pool(difficulty)
	assert(not pool.is_empty(), "No moves for difficulty %d" % difficulty)

	var out: Array[Move] = []
	var last: Move = null
	for i in count:
		var move: Move = pool.pick_random()
		if not allow_repeats and pool.size() > 1:
			while move == last:
				move = pool.pick_random()
		out.append(move)
		last = move
	return out

func apply_move(move: Move) -> void:
	stance = move.stance
	arm_l = move.arm_l
	arm_r = move.arm_r
	hips = move.hips
	# head_pose = move.head_pose

func get_move() -> Move:
	return Move.new(stance, arm_l, arm_r, hips)


class Move:
	var stance: Stance
	var arm_l: ArmPose
	var arm_r: ArmPose
	var hips: HipsPose

	func _init(p_stance: Stance, p_arm_l: ArmPose, p_arm_r: ArmPose, p_hips: HipsPose) -> void:
		stance = p_stance
		arm_l = p_arm_l
		arm_r = p_arm_r
		hips = p_hips

	func equals(other: Move) -> bool:
		return stance == other.stance and arm_l == other.arm_l and arm_r == other.arm_r and hips == other.hips

	func _to_string() -> String:
		return "Move(stance=%s, arm_l=%s, arm_r=%s, hips=%s)" % [
			Stance.keys()[stance],
			ArmPose.keys()[arm_l],
			ArmPose.keys()[arm_r],
			HipsPose.keys()[hips],
		]
