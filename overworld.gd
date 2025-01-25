extends Node2D

@onready var game_area: TileMapLayer = $GameArea

const CELL_SIZE := Vector2i(32, 32)
const HALF_CELL_SIZE := Vector2i(16, 16)
const QUARTER_CELL_SIZE := Vector2i(8, 8)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(game_area.get_used_cells())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_all_tile_positions(tilemaplayer: TileMapLayer, layer: int) -> Array:
	var tile_positions = []
	
	# Get the used rect of the TileMap (area with tiles)
	var used_rect = tilemaplayer.get_used_rect()
	
	# Iterate through the cells in the used rect
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell_position = Vector2i(x, y)
			
			# Check if a tile exists at this position
			if tilemaplayer.get_cell_source_id(cell_position) != -1:
				tile_positions.append(cell_position)
	
	return tile_positions
