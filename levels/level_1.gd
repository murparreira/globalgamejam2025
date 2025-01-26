extends Node2D

@onready var game_area: TileMapLayer = $Visuals/GameArea
@onready var player: Player = $Player
@onready var hint_label: RichTextLabel = $HUD/HintLabel
@onready var city: City = $City
@onready var tube: Tube = $Tube
@onready var o_2_label_value: Label = $HUD/PanelContainer/VBoxContainer/O2LabelValue

var cities_positions : Array = []
var current_selected_city : City
var current_selected_tube : Tube

func _ready() -> void:
	hint_label.visible = false
	
	tube.set_starting_position(Vector2i(2, 1))

	if GameData.data['current_player_position'] != null:
		player.set_starting_position(GameData.data['current_player_position'])
	else:
		player.set_starting_position(Vector2i(0, 3))
	
	if GameData.data['current_oxygen'] != null:
		o_2_label_value.text = str(GameData.data['current_oxygen'])

	player.animated_sprite_2d.play()
	player.player_moved.connect(_on_player_moved)
	var cities = get_tree().get_nodes_in_group("cities")
	for city in cities:
		cities_positions.append({
			"position": game_area.local_to_map(city.position),
			"city": city
		})
		if GameData.data['levels']['level_1']['cities'][city.city_name]['completed']:
			#var tween = get_tree().create_tween()
			#city.sprite_2d.modulate = Color(0.3, 0.3, 0.3, 1)
			#tween.tween_property(city.sprite_2d, "modulate", Color(1, 1, 1, 1), 1.0)
			city.sprite_2d.material = ShaderMaterial.new()
			city.sprite_2d.material.shader = load("res://bw.gdshader")
	
	print("USED CELLS: ")
	print(game_area.get_used_cells())
	print("CITIES POSITIONS: ")
	print(cities_positions)
	
func get_all_tile_positions(tilemaplayer: TileMapLayer, layer: int) -> Array:
	var tile_positions = []
	var used_rect = tilemaplayer.get_used_rect()
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell_position = Vector2i(x, y)
			if tilemaplayer.get_cell_source_id(cell_position) != -1:
				tile_positions.append(cell_position)
	return tile_positions

func _on_player_moved(player_position: Vector2i) -> void:
	if o_2_label_value != null:
		o_2_label_value.text = str(GameData.data["current_oxygen"])

	if game_area.local_to_map(tube.position) == player_position:
		hint_label.visible = true
		current_selected_tube = tube
		print("Selected Tube: ", current_selected_tube.name)

	for city_data in cities_positions:
		if city_data["position"] == player_position:
			var blink_duration: float = 1.0
			var tween = get_tree().create_tween()
			hint_label.modulate = Color(1, 1, 1, 1)
			tween.tween_property(hint_label, "modulate:a", 0.0, blink_duration / 2)
			tween.tween_property(hint_label, "modulate:a", 1.0, blink_duration / 2)
			tween.set_loops()
			hint_label.visible = true
			current_selected_city = city_data["city"]
			print("Selected City: ", current_selected_city.city_name)
			return
	
	hint_label.visible = false
	current_selected_city = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if current_selected_tube != null:
			if !GameData.data['levels']['level_1']['tube']:
				print("SPACEBAR pressed in tube: ", current_selected_tube.name)
				GameData.data['current_minigame_tube'] = current_selected_tube.name
				SceneManager.swap_scenes("res://levels/minigame_tube.tscn", get_tree().root, self, "fade_to_black")
		else:
			print("SPACEBAR pressed, but not in a city.")
		if current_selected_city != null:
			if !GameData.data['levels']['level_1']['cities'][current_selected_city.city_name]['completed']:
				print("SPACEBAR pressed in city: ", current_selected_city.city_name)
				GameData.data['current_minigame_city'] = current_selected_city.city_name
				SceneManager.swap_scenes("res://levels/minigame.tscn", get_tree().root, self, "fade_to_black")
		else:
			print("SPACEBAR pressed, but not in a city.")
