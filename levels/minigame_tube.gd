extends Node2D

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

func _ready() -> void:
	var sample_keys = ['A', 'D', 'A', 'D', 'A', 'D', 'A', 'D', 'A', 'D']
	for i in range(balls.size()):
		balls[i].key = sample_keys[i]
	
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	for ball in balls:
		move_ball_to_left(ball)

func move_ball_to_left(ball: Ball) -> void:
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

func disable_ball_collider(ball: Ball) -> void:
	# Disable the ball's collider when it passes the contact area
	var collision_shape = ball.get_child(0) as CollisionShape2D
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_a"):
		check_ball_input("A")
	if Input.is_action_just_pressed("ui_d"):
		check_ball_input("D")

func check_ball_input(input_key: String) -> void:
	for ball in balls:
		if contact_area.overlaps_area(ball) and ball.key == input_key:
			print("Correct input! Ball matched: ", ball.name)
			correct_balls += 1
			update_oxygen_cylinder()
			disable_ball_collider(ball)  # Disable the collider immediately
			break

func update_oxygen_cylinder() -> void:
	var total_balls = balls.size()
	var oxygen_percentage = (correct_balls / float(total_balls)) * 100
	print("Oxygen cylinder filled: ", oxygen_percentage, "%")
	# Display the message to the player
	display_oxygen_message(oxygen_percentage)

func display_oxygen_message(percentage: float) -> void:
	# Example: Update a label or UI element to show the oxygen percentage
	var message = "Oxygen cylinder filled: %.1f%%" % percentage
	print(message)  # Replace this with your UI update logic
