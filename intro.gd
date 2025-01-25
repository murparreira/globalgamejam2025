extends Node2D

@onready var rich_text_label: RichTextLabel = $Container/RichTextLabel

func _ready() -> void:
	var intro_texts = [
		"Há 20 anos ocorreu um acidente nuclear que culminou na contaminação de pessoas, animais, plantas, solo, água e ar.",
		"Muitos sofreram danos irreversíveis, ocasionando o óbito em pouco tempo. Os restantes padeceram com as sequelas deixadas por todo o lado.",
		"Em uma tentativa de sobrevivência, pequenos grupos sob suporte do governo construíram locais seguros para morar, preparados para as atuais intempéries.",
		"Nesse ambiente, em 2022, pós-acidente nuclear, encontramos nosso personagem, funcionário público, em seu primeiro mês de trabalho. Ele deve realizar as entregas nas cidades sinalizadas, utilizando seu cilindro de O2. Procure o trajeto mais adequado e otimizável. Mas lembre-se, durante o trajeto terá locais para reabastecer o cilindro de O2.",
		"Cuidado para não ficar sem AAAAA.......R."
	]
	for text in intro_texts:
		rich_text_label.text = text
		rich_text_label.visible_ratio = 0.0

		var tween: Tween = create_tween()
		tween.tween_property(rich_text_label, "visible_ratio", 1.0, 4.0).from(0.0)

		await tween.finished
		await get_tree().create_timer(1.0).timeout
	
	SceneManager.swap_scenes("res://overworld.tscn", get_tree().root, self, "fade_to_black")
