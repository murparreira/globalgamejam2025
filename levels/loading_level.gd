extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	# Get the player's size from its sprite or collision shape
	var player_size: Vector2 = get_player_size()

	# Set the player's initial position outside the left side of the screen
	player.position.x = -player_size.x

	# Create a tween to move the player to the right side of the screen
	var tween = create_tween()
	tween.tween_property(player, "position:x", 1920 + player_size.x, 2.0)
	tween.tween_callback(_on_player_exit_screen)

func get_player_size() -> Vector2:
	# Attempt to get the size from the player's sprite
	if player.has_node("Sprite2D"):
		var sprite: Sprite2D = player.get_node("Sprite2D")
		return sprite.texture.get_size() * sprite.scale

	# Attempt to get the size from the player's collision shape
	if player.has_node("CollisionShape2D"):
		var collision_shape: CollisionShape2D = player.get_node("CollisionShape2D")
		if collision_shape.shape is RectangleShape2D:
			return collision_shape.shape.extents * 2
		elif collision_shape.shape is CircleShape2D:
			return Vector2(collision_shape.shape.radius * 2, collision_shape.shape.radius * 2)

	# Default size if no sprite or collision shape is found
	return Vector2(32, 32)  # Adjust this to match your player's size

func _on_player_exit_screen() -> void:
	print("Player has exited the screen. Transitioning to the next level...")
	
	# Get the current level from GameData
	var current_level: String = GameData.data["current_level"]
	
	# Extract the level number (e.g., "1" from "level_1")
	var level_number = int(current_level.split("_")[1])
	
	# Increment the level number
	var next_level_number = level_number + 1
	
	# Construct the next level string (e.g., "level_2")
	var next_level = "level_" + str(next_level_number)
	
	# Update GameData with the next level
	GameData.data["current_level"] = next_level
	
	# Transition to the next level
	SceneManager.swap_scenes("res://levels/" + next_level + ".tscn", get_tree().root, self, "fade_to_black")
