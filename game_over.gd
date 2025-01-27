extends CanvasLayer

@onready var quit_button: Button = %QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.crossfade_to(MusicManager.main_music, 0.5)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	SceneManager.swap_scenes("res://main_menu.tscn", get_tree().root, self, "fade_to_black")
