# SfxManager.gd
extends Node

# Preload audio files
const CORRECT_SOUND = preload("res://assets/minigame_action_accept.ogg")
const WRONG_SOUND = preload("res://assets/minigame_action_wrong.ogg")

const FOOTSTEP_SOUNDS = [
	preload("res://assets/player_footstep01.ogg"),
	preload("res://assets/player_footstep02.ogg"),
]

# AudioStreamPlayer instances
var audio_player_correct: AudioStreamPlayer
var audio_player_wrong: AudioStreamPlayer
var audio_player_footsteps: AudioStreamPlayer

func _ready():
	# Create and configure the correct sound player
	audio_player_correct = AudioStreamPlayer.new()
	audio_player_correct.stream = CORRECT_SOUND
	audio_player_correct.bus = "SFX"  # Assign to the SFX bus (ensure this bus exists in your audio settings)
	add_child(audio_player_correct)

	# Create and configure the wrong sound player
	audio_player_wrong = AudioStreamPlayer.new()
	audio_player_wrong.stream = WRONG_SOUND
	audio_player_wrong.bus = "SFX"  # Assign to the SFX bus
	add_child(audio_player_wrong)
	
	audio_player_footsteps = AudioStreamPlayer.new()
	audio_player_footsteps.stream = FOOTSTEP_SOUNDS.pick_random()
	audio_player_footsteps.bus = "SFX"  # Assign to the SFX bus (ensure this bus exists in your audio settings)
	add_child(audio_player_correct)

func play_correct():
	call_deferred("_play_correct")

func _play_correct():
	if not audio_player_correct.playing:
		audio_player_correct.play()

func play_wrong():
	call_deferred("_play_wrong")

func _play_wrong():
	if not audio_player_wrong.playing:
		audio_player_wrong.play()

func play_footsteps():
	call_deferred("_play_footsteps")

func _play_footsteps():
	if not audio_player_footsteps.playing:
		audio_player_footsteps.play()
