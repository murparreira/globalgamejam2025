extends Node2D

@onready var story_label: RichTextLabel = $Container/StoryLabel
@onready var hint_label: RichTextLabel = $Container/HintLabel

var intro_texts: Array = [
	"Há 20 anos ocorreu um acidente nuclear que culminou na contaminação de pessoas, animais, plantas, solo, água e ar. Houve danos irreversíveis, deixando sequelas por todo o lado.",
	"Mesmo com a devastação, os sobreviventes se reuniram em pequenas grupos com o suporte do governo e construíram locais seguros, com a utilização de cúpulas para morar, preparados para as atuais intempéries.",
	"Nesse ambiente, já em 2022, encontramos nosso personagem, funcionário público, em seu primeiro mês de trabalho.\n\nEle precisa realizar entregas nas cidades sinalizadas, utilizando seu cilindro de O2, para se locomover fora da cúpula. Você deve procurar o trajeto mais adequado e otimizável. Mas lembre-se, durante o trajeto terá locais para reabastecer o cilindro de O2.\n\nCuidado para não ficar sem a..a..a..a.ar.",
]

var current_text_index: int = 0
var current_tween: Tween

func _ready() -> void:
	show_next_text()

	var blink_duration: float = 1.0
	var tween = get_tree().create_tween()
	# Set the initial alpha to fully visible (1.0)
	hint_label.modulate = Color(1, 1, 1, 1)
	# Animate the alpha channel to 0 (fully transparent)
	tween.tween_property(hint_label, "modulate:a", 0.0, blink_duration / 2)
	# Animate the alpha channel back to 1 (fully visible)
	tween.tween_property(hint_label, "modulate:a", 1.0, blink_duration / 2)
	# Loop the animation indefinitely
	tween.set_loops()

func show_next_text() -> void:
	if current_text_index >= intro_texts.size():
		# All texts have been shown, transition to the next scene
		SceneManager.swap_scenes("res://levels/level_1.tscn", get_tree().root, self, "fade_to_black")
		return

	story_label.text = intro_texts[current_text_index]
	story_label.visible_ratio = 0.0

	current_tween = create_tween()
	current_tween.tween_property(story_label, "visible_ratio", 1.0, 8.0).from(0.0)

	# Wait for the tween to finish or for the player to press SPACEBAR
	await current_tween.finished
	var seconds = 2.0
	if current_text_index == 2:
		seconds = 4.0
	await get_tree().create_timer(seconds).timeout
	current_text_index += 1
	show_next_text()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # SPACEBAR is mapped to "ui_accept"
		if current_tween != null and current_tween.is_running():
			# Fast-forward the current text
			current_tween.kill()
			story_label.visible_ratio = 1.0
		else:
			# Proceed to the next text
			current_text_index += 1
			show_next_text()
