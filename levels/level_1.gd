extends Node2D

@onready var game_area: TileMapLayer = $Visuals/GameArea
@onready var player: Player = $Player
@onready var hint_label: RichTextLabel = $HUD/HintLabel
@onready var city: City = $City
@onready var tube: Tube = $Tube
@onready var o_2_label_value: Label = $HUD/PanelContainer/VBoxContainer/O2LabelValue

var cities_positions: Array = []
var current_selected_city: City
var current_selected_tube: Tube

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	hint_label.visible = false

	# Set up tube and player positions
	tube.set_starting_position(Vector2i(2, 1))
	var player_starting_position = GameData.data.get('current_player_position', Vector2i(0, 3))
	if player_starting_position == null:
		player_starting_position = Vector2i(0, 3)
	player.set_starting_position(player_starting_position)
	o_2_label_value.text = str(GameData.data.get('current_oxygen', 0))

	player.animated_sprite_2d.play()
	player.player_moved.connect(_on_player_moved)

	# Initialize cities
	initialize_cities()

	print("USED CELLS: ", game_area.get_used_cells())
	print("CITIES POSITIONS: ", cities_positions)

func initialize_cities() -> void:
	var cities = get_tree().get_nodes_in_group("cities")
	for city in cities:
		cities_positions.append({
			"position": game_area.local_to_map(city.position),
			"city": city
		})
		if GameData.data['levels']['level_1']['cities'][city.city_name]['completed']:
			city.sprite_2d.material = ShaderMaterial.new()
			city.sprite_2d.material.shader = load("res://bw.gdshader")

func _on_player_moved(player_position: Vector2i) -> void:
	update_oxygen_display()
	check_tube_collision(player_position)
	check_city_collision(player_position)

func update_oxygen_display() -> void:
	if o_2_label_value:
		o_2_label_value.text = str(GameData.data["current_oxygen"])

func check_tube_collision(player_position: Vector2i) -> void:
	if game_area.local_to_map(tube.position) == player_position:
		hint_label.visible = true
		current_selected_tube = tube
		print("Selected Tube: ", current_selected_tube.name)
		return
	current_selected_tube = null

func check_city_collision(player_position: Vector2i) -> void:
	for city_data in cities_positions:
		if city_data["position"] == player_position:
			start_hint_blink()
			current_selected_city = city_data["city"]
			print("Selected City: ", current_selected_city.city_name)
			return

	hint_label.visible = false
	current_selected_city = null

func start_hint_blink() -> void:
	hint_label.visible = true
	var blink_duration: float = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(hint_label, "modulate:a", 0.0, blink_duration / 2)
	tween.tween_property(hint_label, "modulate:a", 1.0, blink_duration / 2)
	tween.set_loops()

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
	if !GameData.data['levels']['level_1']['tube']:
		print("SPACEBAR pressed in tube: ", current_selected_tube.name)
		GameData.data['current_minigame_tube'] = current_selected_tube.name
		SceneManager.swap_scenes("res://levels/minigame_tube.tscn", get_tree().root, self, "fade_to_black")

func handle_city_interaction() -> void:
	if !GameData.data['levels']['level_1']['cities'][current_selected_city.city_name]['completed']:
		print("SPACEBAR pressed in city: ", current_selected_city.city_name)
		GameData.data['current_minigame_city'] = current_selected_city.city_name
		SceneManager.swap_scenes("res://levels/minigame.tscn", get_tree().root, self, "fade_to_black")

func check_all_cities_cleared() -> bool:
	for city_data in cities_positions:
		if !GameData.data['levels']['level_1']['cities'][city_data["city"].city_name]['completed']:
			return false
	return true

func _process(delta: float) -> void:
	if check_all_cities_cleared():
		GameData.set_defaults()
		print("All cities cleared! Proceeding to the next level...")
		SceneManager.swap_scenes("res://levels/loading_level.tscn", get_tree().root, self, "fade_to_black")
