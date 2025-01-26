class_name City extends Node2D

@export var city_name : String = 'city_1'
@export var city_sprite : Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var playable_area: Array
var game_area : TileMapLayer

signal player_moved(player_position: Vector2i)

func _ready() -> void:
	if city_sprite != null:
		sprite_2d.texture = city_sprite
	game_area = get_tree().get_first_node_in_group("game_area")
	playable_area = game_area.get_used_cells()

func move_to_cell(direction: Vector2i) -> void:
	var current_grid_position = game_area.local_to_map(position)
	var target_grid_position = current_grid_position + direction
	
	if !playable_area.has(target_grid_position):
		return

	global_position = game_area.map_to_local(target_grid_position)
	global_position.x -= 16
	global_position.y -= 16
