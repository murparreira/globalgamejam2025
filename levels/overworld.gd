extends Node2D

@onready var game_area: TileMapLayer = $GameArea
@onready var player: Player = $Player
@onready var interact_label: RichTextLabel = $Visuals/HUD/InteractLabel
@onready var city1: City = $City

const CELL_SIZE := Vector2i(32, 32)
const HALF_CELL_SIZE := Vector2i(16, 16)
const QUARTER_CELL_SIZE := Vector2i(8, 8)

var cities_positions : Array = []
var current_selected_city : City

func _ready() -> void:
	interact_label.visible = false
	player.move_to_cell(Vector2i(2, 15))
	#city1.move_to_cell(Vector2i(2, 15))
	player.animated_sprite_2d.play()
	player.player_moved.connect(_on_player_moved)
	var cities = get_tree().get_nodes_in_group("cities")
	for city in cities:
		cities_positions.append({
			"position": game_area.local_to_map(city.position),
			"city": city
		})
	
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
	for city_data in cities_positions:
		if city_data["position"] == player_position:
			interact_label.visible = true
			current_selected_city = city_data["city"]
			print("Selected City: ", current_selected_city.name)
			print("Minigame: ", current_selected_city.minigame)
			print("Cleared: ", current_selected_city.cleared)
			return
	
	interact_label.visible = false
	current_selected_city = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if current_selected_city != null:
			print("SPACEBAR pressed in city: ", current_selected_city.name)
			SceneManager.swap_scenes("res://minigame.tscn", get_tree().root, self, "fade_to_black")
		else:
			print("SPACEBAR pressed, but not in a city.")
