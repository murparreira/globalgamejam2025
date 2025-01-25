class_name Player extends Node2D

@onready var oxygen_levels := 100
@onready var oxygen_level: RichTextLabel = $"../Visuals/HUD/OxygenLevel"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var target_position: Vector2i
var playable_area: Array
var game_area : TileMapLayer

signal player_moved(player_position: Vector2i)

func _ready() -> void:
	animated_sprite_2d.play()
	game_area = get_tree().get_first_node_in_group("game_area")
	playable_area = game_area.get_used_cells()

func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("ui_down"):
		direction = Vector2.DOWN
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2.RIGHT

	if direction != Vector2.ZERO:
		move_to_cell(direction)

func move_to_cell(direction: Vector2i) -> void:
	oxygen_levels -= 1
	oxygen_level.text = str(oxygen_levels)

	var current_grid_position = game_area.local_to_map(position)
	var target_grid_position = current_grid_position + direction
	
	if !playable_area.has(target_grid_position):
		return

	player_moved.emit(target_grid_position)

	global_position = game_area.map_to_local(target_grid_position)
	global_position.x -= 16
	global_position.y -= 16
