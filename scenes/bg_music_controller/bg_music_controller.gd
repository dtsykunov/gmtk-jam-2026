extends Node

const TIER_CLIPS := [0, 1, 2]

@onready var _player: AudioStreamPlayer = $AudioStreamPlayer

var _current_tier := -1


func _ready() -> void:
	SceneLoader.scene_loaded.connect(_on_scene_loaded)


func _on_scene_loaded() -> void:
	if SceneLoader.is_loading_scene(AppConfig.main_menu_scene_path):
		_player.stop()
		_current_tier = -1


func play_intro() -> void:
	_current_tier = 0
	_player.play()


func on_difficulty_changed(difficulty: int) -> void:
	var tier := _tier_for_difficulty(difficulty)
	if tier == _current_tier or tier == 0:
		return
	_current_tier = tier

	var playback := _player.get_stream_playback() as AudioStreamPlaybackInteractive
	if playback:
		playback.switch_to_clip(TIER_CLIPS[tier])


func _tier_for_difficulty(difficulty: int) -> int:
	if difficulty >= 7:
		return 2
	if difficulty >= 3:
		return 1
	return 0
