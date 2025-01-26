extends CanvasLayer

@onready var game_over_panel: MarginContainer = $GameOverPanel
@onready var hint_label: RichTextLabel = $HintLabel
@onready var o_2_label_value: Label = $PanelContainer/VBoxContainer/O2LabelValue

func _ready() -> void:
	game_over_panel.visible = false
	hint_label.visible = false
