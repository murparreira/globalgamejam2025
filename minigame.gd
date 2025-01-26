extends Node2D

@onready var arrow: Node2D = $GameContainer/Arrow
@onready var arrow_collider: Area2D = $GameContainer/Arrow/Area2D

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

func _ready() -> void:
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
			game_over_label.text = "Bom, não se pode ganhar todas não é mesmo? :("
		else:
			if wins.size() == 3:
				game_over_label.visible = true
				game_over_label.text = "É isso aí, mais uma entrega completada. :)"
