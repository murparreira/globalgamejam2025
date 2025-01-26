class_name Tube extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var tube_name: String = 'tube_1'

var playable_area: Array
var game_area : TileMapLayer

func _ready() -> void:
	animated_sprite_2d.play()
	game_area = get_tree().get_first_node_in_group("game_area")
	if game_area == null:
		return
	playable_area = game_area.get_used_cells()

func set_starting_position(starting_position: Vector2i) -> void:
	var current_grid_position = game_area.local_to_map(position)
	if !playable_area.has(starting_position):
		return
	global_position = game_area.map_to_local(starting_position)
