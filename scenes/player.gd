class_name Player extends Node2D

@onready var oxygen_levels := 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var movement_enabled : bool = true

var target_position: Vector2i
var playable_area: Array
var game_area : TileMapLayer

signal player_moved(player_position: Vector2i, oxygen_levels: int)

func _ready() -> void:
	z_index = 99
	animated_sprite_2d.play()
	game_area = get_tree().get_first_node_in_group("game_area")
	if game_area == null:
		return
	playable_area = game_area.get_used_cells()

func _process(delta: float) -> void:
	if !movement_enabled:
		return
	var direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("ui_down"):
		direction = Vector2.DOWN
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2.LEFT
		animated_sprite_2d.flip_h = true
	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2.RIGHT
		animated_sprite_2d.flip_h = false

	if direction != Vector2.ZERO:
		move_to_cell(direction)

func set_starting_position(starting_position: Vector2i) -> void:
	var current_grid_position = game_area.local_to_map(position)
	if !playable_area.has(starting_position):
		return
	global_position = game_area.map_to_local(starting_position)

func move_to_cell(direction: Vector2i) -> void:
	var current_grid_position = game_area.local_to_map(position)
	var target_grid_position = current_grid_position + direction
	
	if !playable_area.has(target_grid_position):
		return
	
	#MusicManager.play_sfx(MusicManager.footsteps_sfx_example.pick_random())
	player_moved.emit(target_grid_position)
	GameData.data['current_player_position'] = target_grid_position

	global_position = game_area.map_to_local(target_grid_position)
