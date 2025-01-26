extends Node2D

@onready var arrow: Node2D = $GameContainer/Arrow
@onready var arrow_collider: Area2D = $GameContainer/Arrow/Area2D
@onready var player: Player = $Player

@onready var game_over_label: RichTextLabel = $GameOverLabel

@onready var stop_areas: Array[Node2D] = [$GameContainer/StopArea1, $GameContainer/StopArea2, $GameContainer/StopArea3]
@onready var stop_area_colliders: Array[Area2D] = [
	$GameContainer/StopArea1/Area2D,
	$GameContainer/StopArea2/Area2D,
	$GameContainer/StopArea3/Area2D
]

var tween: Tween = create_tween().set_loops()
var wins : Array = []
var continue_playing : bool = false

signal minigame_ended

func _ready() -> void:
	minigame_ended.connect(_on_minigame_ended)
	game_over_label.visible = false
	arrow.position.x = 10

	# Initialize the tween for the arrow
	tween = create_tween().set_loops()
	var start_x := arrow.position.x
	var end_x := arrow.position.x + 1920

	tween.tween_property(arrow, "position:x", end_x, 2.0).from(start_x)
	tween.tween_property(arrow, "position:x", start_x, 2.0).from(end_x)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		tween.pause()

		# Check for collisions with any of the stop areas
		for collider in stop_area_colliders:
			if collider == null:
				continue
			if arrow_collider.overlaps_area(collider):
				wins.append(true)
				collider.get_parent().queue_free()
				tween.play()
				continue_playing = true
				break
			else:
				continue_playing = false

		# Display the result
		if !continue_playing:
			game_over_label.visible = true
			game_over_label.text = "Bom, não se pode ganhar todas não é mesmo? :(\n\nVocê perdeu 20% do seu oxigênio!"
			GameData.data["current_oxygen"] -= 20
			GameData.data['levels'][GameData.data['current_level']]['cities'][GameData.data['current_minigame_city']]['completed'] = false
			minigame_ended.emit()
		else:
			if wins.size() == 3:
				game_over_label.visible = true
				game_over_label.text = "É isso aí, mais uma entrega feita, bom trabalho. :)"
				GameData.data['levels'][GameData.data['current_level']]['cities'][GameData.data['current_minigame_city']]['completed'] = true
				minigame_ended.emit()

func _on_minigame_ended() -> void:
	if tween.is_running():
		tween.pause()
	await get_tree().create_timer(3.0).timeout
	SceneManager.swap_scenes("res://levels/" + GameData.data["current_level"] + ".tscn", get_tree().root, self, "fade_to_black")
