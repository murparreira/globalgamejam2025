extends BaseLevel

@onready var city: Node2D = $City
@onready var tube: Tube = $Tube
@onready var tube_2: Tube = $Tube2

func get_level_name() -> String:
	return "level_3"

func setup_tube_positions() -> void:
	tube.set_starting_position(Vector2i(23, 12))
	tube_2.set_starting_position(Vector2i(14, 7))

func get_default_player_position() -> Vector2i:
	return Vector2i(0, 6)

func get_oxygen_consumption_rate() -> int:
	return 2

func get_next_level_scene() -> String:
	return "res://levels/win.tscn"
