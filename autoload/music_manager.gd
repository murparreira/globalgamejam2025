extends Node

# Audio players for music and SFX
var music_player: AudioStreamPlayer
var alternate_music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Preload audio streams
var main_music: AudioStream = preload("res://assets/Mus_Gameplay_1.wav")
var alternate_music: AudioStream = preload("res://assets/Mus_Gameplay_2.wav")
var correct_sfx_example: AudioStream = preload("res://assets/minigame_action_accept.ogg")
var wrong_sfx_example: AudioStream = preload("res://assets/minigame_action_wrong.ogg")
var footsteps_sfx_example: Array[AudioStream] = [
	preload("res://assets/player_footstep01.ogg"),
	preload("res://assets/player_footstep02.ogg")
]
var warning_sfx_example: AudioStream = preload("res://assets/player_warning_low_oxigen.ogg")
var win_sfx_example: AudioStream = preload("res://assets/level_win.ogg")
var lose_sfx_example: AudioStream = preload("res://assets/level_lose.ogg")

# Track the currently playing music and fade state
var current_music: AudioStream = null
var is_fading: bool = false
var current_tween: Tween = null

func _ready():
	# Initialize the music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.autoplay = true
	add_child(music_player)
	
	# Initialize the alternate music player
	alternate_music_player = AudioStreamPlayer.new()
	alternate_music_player.bus = "Music"
	alternate_music_player.autoplay = true
	alternate_music_player.volume_db = -80  # Start muted
	add_child(alternate_music_player)
	
	# Initialize the SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	# Play the main music when the game starts
	play_music(main_music)

func play_music(music: AudioStream) -> void:
	if music_player.stream != music:
		music_player.stream = music
		music_player.play()
		current_music = music

func stop_music() -> void:
	music_player.stop()
	current_music = null

func play_sfx(sfx: AudioStream) -> void:
	sfx_player.stream = sfx
	sfx_player.play()

func stop_sfx() -> void:
	sfx_player.stop()

func crossfade_to(new_music: AudioStream, fade_duration: float = 2.0) -> void:
	# Don't start a new crossfade if we're already fading or if it's the same music
	if is_fading or new_music == current_music:
		return
		
	# Kill any existing tween
	if current_tween:
		current_tween.kill()
	
	is_fading = true
	
	# Set up the alternate music track
	alternate_music_player.stream = new_music
	alternate_music_player.play()
	
	# Create a new tween
	current_tween = create_tween()
	
	# Fade out the current music
	current_tween.parallel().tween_property(music_player, "volume_db", -80, fade_duration)
	
	# Fade in the alternate music
	current_tween.parallel().tween_property(alternate_music_player, "volume_db", 0, fade_duration)
	
	# Set up completion callback
	current_tween.finished.connect(_on_crossfade_completed.bind(new_music))

func _on_crossfade_completed(new_music: AudioStream) -> void:
	_swap_music_players(new_music)
	is_fading = false
	current_tween = null

func _swap_music_players(new_music: AudioStream) -> void:
	# Swap the players
	var temp_player = music_player
	music_player = alternate_music_player
	alternate_music_player = temp_player
	
	# Reset the alternate player's volume
	alternate_music_player.volume_db = -80
	
	# Update the currently playing music
	current_music = new_music
