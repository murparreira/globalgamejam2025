extends CanvasLayer

@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	quit_button.pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	SceneManager.swap_scenes("res://main_menu.tscn", get_tree().root, self, "fade_to_black")
