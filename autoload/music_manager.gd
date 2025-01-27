extends Node

# Audio players for music and SFX
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Preload your audio streams (optional, you can also load them dynamically)
var main_music: AudioStream = preload("res://assets/Mus_Gameplay_1.wav")
var correct_sfx_example: AudioStream = preload("res://assets/minigame_action_accept.ogg")
var wrong_sfx_example: AudioStream = preload("res://assets/minigame_action_wrong.ogg")

func _ready():
	# Initialize the music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"  # Assign to the Music bus
	add_child(music_player)
	
	# Initialize the SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"  # Assign to the SFX bus
	add_child(sfx_player)
	
	# Play the main music when the game starts
	play_music(main_music)

# Function to play music
func play_music(music: AudioStream) -> void:
	if music_player.stream != music:
		music_player.stream = music
	music_player.play()

# Function to stop music
func stop_music() -> void:
	music_player.stop()

# Function to play SFX
func play_sfx(sfx: AudioStream) -> void:
	sfx_player.stream = sfx
	sfx_player.play()

# Function to stop SFX
func stop_sfx() -> void:
	sfx_player.stop()
