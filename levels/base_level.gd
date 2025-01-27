class_name BaseLevel extends Node2D

@onready var game_area: TileMapLayer = $Visuals/GameArea
@onready var player: Player = $Player
@onready var hud: CanvasLayer = $HUD

var cities_positions: Array = []
var tubes_positions: Array = []
var current_selected_city: City
var current_selected_tube: Tube

var data: Dictionary = {}
var scene_swap_triggered: bool = false  # Flag to track scene swaps

func _ready() -> void:
	GameData.data["current_level"] = get_level_name()
	initialize_game()

func get_level_name() -> String:
	return "base_level"  # Override this in child classes

func initialize_game() -> void:
	scene_swap_triggered = false  # Reset the flag
	# Set up tube and player positions
	setup_tube_positions()
	var player_starting_position = GameData.data.get('current_player_position', Vector2i(0, 3))
	if player_starting_position == null:
		player_starting_position = get_default_player_position()
	player.set_starting_position(player_starting_position)
	hud.o_2_label_value.text = str(GameData.data.get('current_oxygen', 0))

	player.animated_sprite_2d.play()
	player.player_moved.connect(_on_player_moved)

	# Initialize cities
	initialize_cities()
	
	# Re-check the player's position to update selected city or tube
	recheck_player_position()

	print("USED CELLS: ", game_area.get_used_cells())
	print("CITIES POSITIONS: ", cities_positions)

func setup_tube_positions() -> void:
	pass  # Override this in child classes

func get_default_player_position() -> Vector2i:
	return Vector2i(0, 0)  # Override this in child classes

func initialize_cities() -> void:
	var cities = get_tree().get_nodes_in_group("cities")
	var tubes = get_tree().get_nodes_in_group("tubes")

	for vtube in tubes:
		tubes_positions.append({
			"position": game_area.local_to_map(vtube.position),
			"tube": vtube
		})
		if GameData.data['levels'][get_level_name()]['tubes'][vtube.tube_name]['completed']:
			vtube.animated_sprite_2d.material = ShaderMaterial.new()
			vtube.animated_sprite_2d.material.shader = load("res://bw.gdshader")

	for city in cities:
		cities_positions.append({
			"position": game_area.local_to_map(city.position),
			"city": city
		})
		if GameData.data['levels'][get_level_name()]['cities'][city.city_name]['completed']:
			city.sprite_2d.material = ShaderMaterial.new()
			city.sprite_2d.material.shader = load("res://bw.gdshader")

func _on_player_moved(player_position: Vector2i) -> void:
	update_oxygen_display()
	check_tube_collision(player_position)
	check_city_collision(player_position)

func update_oxygen_display() -> void:
	if hud.o_2_label_value:
		GameData.data["current_oxygen"] -= get_oxygen_consumption_rate()
		hud.o_2_label_value.text = str(GameData.data["current_oxygen"])

		if GameData.data["current_oxygen"] < 40:
			MusicManager.crossfade_to(MusicManager.alternate_music, 0.5)
		else:
			MusicManager.crossfade_to(MusicManager.main_music, 0.5)

func get_oxygen_consumption_rate() -> int:
	return 1  # Override this in child classes

func check_tube_collision(player_position: Vector2i) -> void:
	for tube_data in tubes_positions:
		if tube_data["position"] == player_position:
			current_selected_tube = tube_data["tube"]
			print("Selected Tube: ", current_selected_tube.name)
			return

	current_selected_tube = null

func check_city_collision(player_position: Vector2i) -> void:
	for city_data in cities_positions:
		if city_data["position"] == player_position:
			current_selected_city = city_data["city"]
			print("Selected City: ", current_selected_city.city_name)
			return

	current_selected_city = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		handle_accept_input()

func handle_accept_input() -> void:
	if current_selected_tube:
		handle_tube_interaction()
	elif current_selected_city:
		handle_city_interaction()
	else:
		print("SPACEBAR pressed, but not in a city or tube.")

func handle_tube_interaction() -> void:
	if !GameData.data['levels'][get_level_name()]['tubes'][current_selected_tube.tube_name]['completed']:
		print("SPACEBAR pressed in tube: ", current_selected_tube.tube_name)
		GameData.data['current_minigame_tube'] = current_selected_tube.tube_name
		SceneManager.swap_scenes("res://levels/minigame_tube.tscn", get_tree().root, self, "fade_to_black")

func handle_city_interaction() -> void:
	if !GameData.data['levels'][get_level_name()]['cities'][current_selected_city.city_name]['completed']:
		print("SPACEBAR pressed in city: ", current_selected_city.city_name)
		GameData.data['current_minigame_city'] = current_selected_city.city_name
		SceneManager.swap_scenes("res://levels/minigame.tscn", get_tree().root, self, "fade_to_black")

func check_all_cities_cleared() -> bool:
	for city_data in cities_positions:
		if !GameData.data['levels'][get_level_name()]['cities'][city_data["city"].city_name]['completed']:
			return false
	return true

func _process(_delta: float) -> void:
	if scene_swap_triggered:
		return  # Exit early if a scene swap has already been triggered

	if check_all_cities_cleared():
		GameData.set_defaults()
		print("All cities cleared! Proceeding to the next level...")
		scene_swap_triggered = true  # Set the flag to prevent further calls
		SceneManager.swap_scenes(get_next_level_scene(), get_tree().root, self, "fade_to_black")

	if GameData.data["current_oxygen"] <= 0:
		MusicManager.play_sfx(MusicManager.lose_sfx_example)
		print("Oxygen depleted! Game over...")
		scene_swap_triggered = true  # Set the flag to prevent further calls
		SceneManager.swap_scenes("res://game_over.tscn", get_tree().root, self, "fade_to_black")

func get_next_level_scene() -> String:
	return "res://levels/loading_level.tscn"  # Override this in child classes

func recheck_player_position() -> void:
	var player_position = game_area.local_to_map(player.position)
	check_tube_collision(player_position)
	check_city_collision(player_position)

func get_data() -> Dictionary:
	data["current_selected_city"] = current_selected_city
	return data
