extends Node2D

@onready var rich_text_label: RichTextLabel = $Container/RichTextLabel

var intro_texts: Array = [
	"Há 20 anos ocorreu um acidente nuclear que culminou na contaminação de pessoas, animais, plantas, solo, água e ar.",
	"Muitos sofreram danos irreversíveis, ocasionando o óbito em pouco tempo. Os restantes padeceram com as sequelas deixadas por todo o lado.",
	"Em uma tentativa de sobrevivência, pequenos grupos sob suporte do governo construíram locais seguros para morar, preparados para as atuais intempéries.",
	"Nesse ambiente, em 2022, pós-acidente nuclear, encontramos nosso personagem, funcionário público, em seu primeiro mês de trabalho. Ele deve realizar as entregas nas cidades sinalizadas, utilizando seu cilindro de O2. Procure o trajeto mais adequado e otimizável. Mas lembre-se, durante o trajeto terá locais para reabastecer o cilindro de O2.",
	"Cuidado para não ficar sem AAAAA.......R."
]

var current_text_index: int = 0
var current_tween: Tween

func _ready() -> void:
	show_next_text()

func show_next_text() -> void:
	if current_text_index >= intro_texts.size():
		# All texts have been shown, transition to the next scene
		SceneManager.swap_scenes("res://overworld.tscn", get_tree().root, self, "fade_to_black")
		return

	rich_text_label.text = intro_texts[current_text_index]
	rich_text_label.visible_ratio = 0.0

	current_tween = create_tween()
	current_tween.tween_property(rich_text_label, "visible_ratio", 1.0, 4.0).from(0.0)

	# Wait for the tween to finish or for the player to press SPACEBAR
	await current_tween.finished
	await get_tree().create_timer(1.0).timeout
	current_text_index += 1
	show_next_text()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # SPACEBAR is mapped to "ui_accept"
		if current_tween != null and current_tween.is_running():
			# Fast-forward the current text
			current_tween.kill()
			rich_text_label.visible_ratio = 1.0
		else:
			# Proceed to the next text
			current_text_index += 1
			show_next_text()
