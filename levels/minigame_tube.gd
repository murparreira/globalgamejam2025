extends Node2D

@onready var result_label: RichTextLabel = $ResultLabel
@onready var hint_label: RichTextLabel = $HintLabel
@onready var contact_area: Area2D = $ContactArea
@onready var timer: Timer = $Timer
@onready var ball: Ball = $GameContainer/Ball
@onready var ball_2: Ball = $GameContainer/Ball2
@onready var ball_3: Ball = $GameContainer/Ball3
@onready var ball_4: Ball = $GameContainer/Ball4
@onready var ball_5: Ball = $GameContainer/Ball5
@onready var ball_6: Ball = $GameContainer/Ball6
@onready var ball_7: Ball = $GameContainer/Ball7
@onready var ball_8: Ball = $GameContainer/Ball8
@onready var ball_9: Ball = $GameContainer/Ball9
@onready var ball_10: Ball = $GameContainer/Ball10

@onready var balls: Array[Ball] = [
	ball,
	ball_2,
	ball_3,
	ball_4,
	ball_5,
	ball_6,
	ball_7,
	ball_8,
	ball_9,
	ball_10,
]

# Speed in pixels per second
const BALL_SPEED: float = 400.0

# Track how many balls the player got right
var correct_balls: int = 0
var oxygen_percentage: int = 0

# Track if the minigame is over
var minigame_over: bool = false

var is_hint_blinking: bool = false
var hint_tween: Tween  # Store the tween for the hint label

# Track which balls have been scored
var scored_balls: Array[Ball] = []

func _ready() -> void:
	hint_label.visible = false
	var sample_keys = ['A', 'D', '-', 'D', '-', '-', 'A', 'D', 'A', 'D']
	for i in range(balls.size()):
		balls[i].key = sample_keys[i]
		if balls[i].key == "-":
			hide_and_disable_ball(balls[i])
	
	timer.timeout.connect(_on_timer_timeout)

func hide_and_disable_ball(ball: Ball) -> void:
	# Hide the ball's sprite
	if ball.has_node("Sprite2D"):
		ball.get_node("Sprite2D").visible = false

	# Disable the ball's collision shape
	if ball.has_node("CollisionShape2D"):
		ball.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_timer_timeout() -> void:
	for ball in balls:
		move_ball_to_left(ball)

func move_ball_to_left(ball: Ball) -> void:
	# Skip missing balls
	if ball.key == "-":
		return

	# Calculate the distance to travel
	var start_x = ball.position.x
	var end_x = -100  # Target position
	var distance = abs(start_x - end_x)

	# Calculate the duration based on the distance and speed
	var duration = distance / BALL_SPEED

	# Create a tween to move the ball
	var tween = create_tween()
	tween.tween_property(ball, "position:x", end_x, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(disable_ball_collider.bind(ball))
	tween.tween_callback(check_minigame_over)

func disable_ball_collider(ball: Ball) -> void:
	# Skip missing balls
	if ball.key == "-":
		return

	# Disable the ball's collider when it passes the contact area
	var collision_shape = ball.get_child(0) as CollisionShape2D
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func check_minigame_over() -> void:
	# Check if all balls have finished their tweens
	for ball in balls:
		if ball.key != "-" and ball.position.x > -100:  # Skip missing balls
			return

	# If all balls have passed, set minigame_over to true
	minigame_over = true
	print("Minigame over! Press SPACEBAR to continue.")
	start_hint_blink()  # Start the hint label blinking

func start_hint_blink() -> void:
	if is_hint_blinking:
		return  # If the tween is already running, do nothing

	is_hint_blinking = true
	hint_label.visible = true

	var blink_duration: float = 1.0
	hint_tween = create_tween()
	hint_tween.tween_property(hint_label, "modulate:a", 0.0, blink_duration / 2)
	hint_tween.tween_property(hint_label, "modulate:a", 1.0, blink_duration / 2)
	hint_tween.set_loops()

func stop_hint_blink() -> void:
	if hint_tween:
		hint_tween.kill()  # Stop the tween
	hint_label.modulate = Color(1, 1, 1, 1)  # Reset the label's alpha to fully visible
	hint_label.visible = false
	is_hint_blinking = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_a"):
		check_ball_input("A")
	if Input.is_action_just_pressed("ui_d"):
		check_ball_input("D")

	# Wait for player input after the minigame is over
	if minigame_over:
		result_label.visible = true
		result_label.text = "[center]Resultado da operação: [b]" + str(correct_balls) + " alvos acertados[/b]\n[b]" + str(oxygen_percentage) + "%[/b] do cilindro de oxigenio vai ser recuperado![/center]"
		
		if Input.is_action_just_pressed("ui_accept"):  # SPACEBAR
			SceneManager.swap_scenes("res://levels/" + GameData.data["current_level"] + ".tscn", get_tree().root, self, "fade_to_black")
			print("Proceeding to the next scene...")
			stop_hint_blink()  # Stop the blinking animation

func check_ball_input(input_key: String) -> void:
	for ball in balls:
		if ball.key == "-":
			continue  # Skip missing balls

		if contact_area.overlaps_area(ball) and ball.key == input_key and not ball in scored_balls:
			print("Correct input! Ball matched: ", ball.name)
			correct_balls += 1
			scored_balls.append(ball)  # Mark the ball as scored
			update_oxygen_cylinder()
			disable_ball_collider(ball)  # Disable the collider immediately
			break
		# TODO: Add logic for incorrect input (e.g., penalty, sound effect)

func update_oxygen_cylinder() -> void:
	var total_balls = balls.size()
	oxygen_percentage = (correct_balls / float(total_balls)) * 100
	print("Oxygen cylinder filled: ", oxygen_percentage, "%")
	GameData.data["current_oxygen"] = min(GameData.data["current_oxygen"] + oxygen_percentage, 100)
	# Display the message to the player
	display_oxygen_message(oxygen_percentage)

func display_oxygen_message(percentage: float) -> void:
	# Example: Update a label or UI element to show the oxygen percentage
	var message = "Oxygen cylinder filled: %.1f%%" % percentage
	print(message)  # Replace this with your UI update logic
