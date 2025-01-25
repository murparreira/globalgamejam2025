extends CanvasLayer

func _ready():
	$%PlayButton.pressed.connect(on_play_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)

func on_play_pressed():
	SceneManager.swap_scenes("res://intro.tscn", get_tree().root, self, "fade_to_black")
	
func on_quit_pressed():
	get_tree().quit()
