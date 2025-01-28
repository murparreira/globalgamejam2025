extends Node2D

class_name Minigame

# Constants
const MIN_STOP_AREA_X: int = 256
const MAX_STOP_AREA_X: int = 1540  # 1920 - 380
const MIN_STOP_AREA_DISTANCE: int = 200
const MAX_PLACEMENT_ATTEMPTS: int = 100
const ARROW_MOVEMENT_TIME: float = 2.0
const GAME_OVER_DELAY: float = 3.0
const OXYGEN_PENALTY: int = 20

# Onready variables for nodes
@onready var arrow: Node2D = $GameContainer/Arrow
@onready var arrow_collider: Area2D = $GameContainer/Arrow/Area2D
@onready var player: Player = $Player
@onready var color_rect: ColorRect = $ColorRect
@onready var city: City = $City
@onready var game_over_label: RichTextLabel = $GameOverLabel

# Stop area references
@onready var stop_areas: Array[Node2D] = [
	$GameContainer/StopArea1,
	$GameContainer/StopArea2,
	$GameContainer/StopArea3
]
@onready var stop_area_colliders: Array[Area2D] = [
	$GameContainer/StopArea1/Area2D,
	$GameContainer/StopArea2/Area2D,
	$GameContainer/StopArea3/Area2D
]

# Game state variables
var tween: Tween
var successful_stops: Array[bool] = []
var can_continue: bool = false
var city_sprite
var is_action_cooldown: bool = false

signal minigame_ended

func _ready() -> void:
	initialize_game()
	setup_arrow_movement()

func initialize_game() -> void:
	city.sprite_2d.texture = city_sprite
	minigame_ended.connect(_on_minigame_ended)
	
	# Initialize UI
	color_rect.visible = false
	game_over_label.visible = false
	arrow.position.x = 10
	
	randomize_stop_areas()

func setup_arrow_movement() -> void:
	tween = create_tween().set_loops()
	var start_x := arrow.position.x
	var end_x := arrow.position.x + 1920

	tween.tween_property(arrow, "position:x", end_x, ARROW_MOVEMENT_TIME).from(start_x)
	tween.tween_property(arrow, "position:x", start_x, ARROW_MOVEMENT_TIME).from(end_x)

func randomize_stop_areas() -> void:
	var placed_positions: Array[int] = []

	for stop_area in stop_areas:
		if not stop_area:
			continue
			
		var position = find_valid_stop_position(placed_positions)
		stop_area.position.x = position
		placed_positions.append(position)

func find_valid_stop_position(placed_positions: Array) -> int:
	for attempt in range(MAX_PLACEMENT_ATTEMPTS):
		var random_x = randi_range(MIN_STOP_AREA_X, MAX_STOP_AREA_X)
		if is_position_valid(random_x, placed_positions):
			return random_x
	
	# Fallback position if no valid position found
	printerr("Warning: Could not place StopArea without overlapping after %d attempts." % MAX_PLACEMENT_ATTEMPTS)
	return MIN_STOP_AREA_X

func is_position_valid(pos: int, placed_positions: Array) -> bool:
	for existing_pos in placed_positions:
		if abs(pos - existing_pos) < MIN_STOP_AREA_DISTANCE:
			return false
	return true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not is_action_cooldown:
		handle_player_input()

func handle_player_input() -> void:
	is_action_cooldown = true
	tween.pause()
	
	if check_stop_area_collision():
		handle_successful_stop()
	else:
		handle_failed_stop()

func check_stop_area_collision() -> bool:
	for collider in stop_area_colliders:
		if collider and arrow_collider.overlaps_area(collider):
			successful_stops.append(true)
			collider.get_parent().queue_free()
			return true
	return false

func handle_successful_stop() -> void:
	MusicManager.play_sfx(MusicManager.correct_sfx_example)
	tween.play()
	can_continue = true
	is_action_cooldown = false
	
	if successful_stops.size() == 3:
		show_victory_screen()

func handle_failed_stop() -> void:
	MusicManager.play_sfx(MusicManager.wrong_sfx_example)
	can_continue = false
	show_failure_screen()

func show_victory_screen() -> void:
	is_action_cooldown = true
	display_game_over("É isso aí, mais uma entrega feita, bom trabalho. :)")
	mark_minigame_completed(true)
	minigame_ended.emit()

func show_failure_screen() -> void:
	display_game_over("Bom, não se pode ganhar todas não é mesmo?\nTente Novamente!\n\nVocê perdeu [b]20%[/b] do seu oxigênio!")
	apply_oxygen_penalty()
	mark_minigame_completed(false)
	minigame_ended.emit()

func display_game_over(message: String) -> void:
	game_over_label.visible = true
	color_rect.visible = true
	game_over_label.text = message

func apply_oxygen_penalty() -> void:
	GameData.data["current_oxygen"] -= OXYGEN_PENALTY

func mark_minigame_completed(completed: bool) -> void:
	GameData.data['levels'][GameData.data['current_level']]['cities'][GameData.data['current_minigame_city']]['completed'] = completed

func _on_minigame_ended() -> void:
	if tween.is_running():
		tween.pause()
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	is_action_cooldown = false
	SceneManager.swap_scenes(
		"res://levels/" + GameData.data["current_level"] + ".tscn",
		get_tree().root,
		self,
		"fade_to_black"
	)

func receive_data(data: Dictionary) -> void:
	city_sprite = data["current_selected_city"].city_sprite
