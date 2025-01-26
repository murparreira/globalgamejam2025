extends CanvasLayer

@onready var game_over_panel: MarginContainer = $GameOverPanel
@onready var hint_label: RichTextLabel = $HintLabel
@onready var o_2_label_value: Label = $PanelContainer/VBoxContainer/O2LabelValue
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	game_over_panel.visible = false
	hint_label.visible = false
	quit_button.pressed.connect(_on_quit_pressed)

func _on_quit_pressed() -> void:
	SceneManager.swap_scenes("res://main_menu.tscn", get_tree().root, self, "fade_to_black")
	get_tree().paused = false
