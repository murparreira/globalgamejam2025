extends Node

var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	var music = load("res://music_v1.wav")  
	audio_player.stream = music
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(_on_music_finished)

func _on_music_finished():
	audio_player.play()

func stop_music():
	audio_player.stop()

func pause_music():
	audio_player.stream_paused = true

func resume_music():
	audio_player.stream_paused = false
