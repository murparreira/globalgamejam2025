extends BaseLevel

@onready var city: Node2D = $City
@onready var tube: Tube = $Tube

func get_level_name() -> String:
	return "level_2"

func setup_tube_positions() -> void:
	tube.set_starting_position(Vector2i(1, 6))

func get_default_player_position() -> Vector2i:
	return Vector2i(4, 4)

func get_oxygen_consumption_rate() -> int:
	return 2

func get_next_level_scene() -> String:
	return "res://levels/loading_level.tscn"
