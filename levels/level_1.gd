extends BaseLevel

@onready var city: City = $City
@onready var tube: Tube = $Tube

func get_level_name() -> String:
	return "level_1"

func setup_tube_positions() -> void:
	tube.set_starting_position(Vector2i(5, 3))

func get_default_player_position() -> Vector2i:
	return Vector2i(1, 0)

func get_oxygen_consumption_rate() -> int:
	return 1

func get_next_level_scene() -> String:
	return "res://levels/loading_level.tscn"
