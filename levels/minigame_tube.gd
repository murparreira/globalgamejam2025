extends Node2D

class_name MinigameTube

# Constants
const BALL_SPEED: float = 400.0
const BLINK_DURATION: float = 1.0
const BALL_END_POSITION: float = -100.0

# Game configuration
const BALL_PATTERNS: Array[Array] = [
	["D", "-", "A", "A", "-", "D", "D", "D", "A", "-"],
	["A", "D", "-", "D", "A", "A", "-", "D", "D", "D"],
	["D", "D", "A", "A", "-", "D", "D", "-", "A", "A"],
	["-", "D", "-", "D", "A", "A", "-", "A", "A", "D"],
	["D", "D", "-", "A", "A", "-", "D", "D", "-", "D"],
	["D", "A", "A", "-", "D", "D", "A", "A", "D", "-"],
	["-", "D", "D", "D", "A", "-", "A", "A", "-", "D"],
	["-", "A", "D", "A", "A", "-", "D", "A", "-", "D"],
	["A", "D", "A", "-", "D", "D", "D", "A", "-", "D"],
	["A", "-", "D", "D", "-", "A", "A", "-", "A", "-"]
]

# Preloaded resources
var button_a = preload("res://assets/button-a.png")
var button_d = preload("res://assets/button-d.png")

# UI Elements
@onready var color_rect: ColorRect = $ColorRect
@onready var result_label: RichTextLabel = $ResultLabel
@onready var hint_label: RichTextLabel = $HintLabel
@onready var contact_area: Area2D = $ContactArea
@onready var timer: Timer = $Timer

# Ball nodes
@onready var balls: Array[Ball] = [
	$GameContainer/Ball,
	$GameContainer/Ball2,
	$GameContainer/Ball3,
	$GameContainer/Ball4,
	$GameContainer/Ball5,
	$GameContainer/Ball6,
	$GameContainer/Ball7,
	$GameContainer/Ball8,
	$GameContainer/Ball9,
	$GameContainer/Ball10
]

# Game state
var correct_balls: int = 0
var oxygen_percentage: int = 0
var minigame_over: bool = false
var is_hint_blinking: bool = false
var hint_tween: Tween
var scored_balls: Array[Ball] = []

func _ready() -> void:
	initialize_game()
	setup_balls()
	connect_signals()

func initialize_game() -> void:
	reset_ui()
	reset_game_state()

func reset_ui() -> void:
	result_label.visible = false
	color_rect.visible = false
	hint_label.visible = false

func reset_game_state() -> void:
	correct_balls = 0
	oxygen_percentage = 0
	minigame_over = false
	is_hint_blinking = false
	scored_balls.clear()

func connect_signals() -> void:
	timer.timeout.connect(_on_timer_timeout)

func setup_balls() -> void:
	var selected_pattern = BALL_PATTERNS.pick_random()
	
	for i in range(balls.size()):
		configure_ball(balls[i], selected_pattern[i])

func configure_ball(ball: Ball, key: String) -> void:
	ball.key = key
	match key:
		"A":
			ball.sprite_2d.texture = button_a
		"D":
			ball.sprite_2d.texture = button_d
		"-":
			hide_and_disable_ball(ball)

func hide_and_disable_ball(ball: Ball) -> void:
	if ball.has_node("Sprite2D"):
		ball.get_node("Sprite2D").visible = false
	if ball.has_node("CollisionShape2D"):
		ball.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_timer_timeout() -> void:
	start_ball_movement()

func start_ball_movement() -> void:
	for ball in balls:
		if ball.key != "-":
			create_ball_movement_tween(ball)

func create_ball_movement_tween(ball: Ball) -> void:
	var distance = abs(ball.position.x - BALL_END_POSITION)
	var duration = distance / BALL_SPEED

	var tween = create_tween()
	tween.tween_property(ball, "position:x", BALL_END_POSITION, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(disable_ball_collider.bind(ball))
	tween.tween_callback(check_minigame_over)

func disable_ball_collider(ball: Ball) -> void:
	if ball.key == "-":
		return
		
	var collision_shape = ball.get_child(0) as CollisionShape2D
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func check_minigame_over() -> void:
	for ball in balls:
		if ball.key != "-" and ball.position.x > BALL_END_POSITION:
			return

	if not minigame_over:
		finish_minigame()

func finish_minigame() -> void:
	minigame_over = true
	mark_minigame_completed()
	update_oxygen_cylinder()
	display_results()
	start_hint_blink()

func mark_minigame_completed() -> void:
	GameData.data['levels'][GameData.data['current_level']]\
		['tubes'][GameData.data['current_minigame_tube']]\
		['completed'] = true

func update_oxygen_cylinder() -> void:
	var active_balls = balls.filter(func(ball): return ball.key != "-").size()
	oxygen_percentage = (correct_balls / float(active_balls)) * 100
	GameData.data["current_oxygen"] = min(
		GameData.data["current_oxygen"] + oxygen_percentage, 
		100
	)

func display_results() -> void:
	result_label.visible = true
	result_label.text = format_result_message()

func format_result_message() -> String:
	return "[center]Resultado da operação: [b]%d alvos acertados[/b]\n\n[b]%d%%[/b] do cilindro de oxigenio vai ser recuperado![/center]" % [
		correct_balls,
		oxygen_percentage
	]

func start_hint_blink() -> void:
	if is_hint_blinking:
		return

	is_hint_blinking = true
	show_hint_ui()
	create_hint_blink_tween()

func show_hint_ui() -> void:
	color_rect.visible = true
	hint_label.visible = true

func create_hint_blink_tween() -> void:
	hint_tween = create_tween()
	hint_tween.tween_property(hint_label, "modulate:a", 0.0, BLINK_DURATION / 2)
	hint_tween.tween_property(hint_label, "modulate:a", 1.0, BLINK_DURATION / 2)
	hint_tween.set_loops()

func stop_hint_blink() -> void:
	if hint_tween:
		hint_tween.kill()
	reset_hint_label()

func reset_hint_label() -> void:
	hint_label.modulate = Color(1, 1, 1, 1)
	hint_label.visible = false
	is_hint_blinking = false

func _process(_delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if not minigame_over:
		handle_gameplay_input()
	else:
		handle_endgame_input()

func handle_gameplay_input() -> void:
	if Input.is_action_just_pressed("ui_a"):
		check_ball_input("A")
	if Input.is_action_just_pressed("ui_d"):
		check_ball_input("D")

func handle_endgame_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		transition_to_next_scene()

func transition_to_next_scene() -> void:
	SceneManager.swap_scenes(
		"res://levels/" + GameData.data["current_level"] + ".tscn",
		get_tree().root,
		self,
		"fade_to_black"
	)
	stop_hint_blink()

func check_ball_input(input_key: String) -> void:
	for ball in balls:
		if should_skip_ball(ball):
			continue

		if is_valid_hit(ball, input_key):
			handle_correct_hit(ball)
			break
		else:
			handle_wrong_hit()

func should_skip_ball(ball: Ball) -> bool:
	return ball.key == "-" or ball in scored_balls

func is_valid_hit(ball: Ball, input_key: String) -> bool:
	return contact_area.overlaps_area(ball) and ball.key == input_key

func handle_correct_hit(ball: Ball) -> void:
	MusicManager.play_sfx(MusicManager.correct_sfx_example)
	correct_balls += 1
	scored_balls.append(ball)
	disable_ball_collider(ball)

func handle_wrong_hit() -> void:
	MusicManager.play_sfx(MusicManager.wrong_sfx_example)
