class_name SpriteTree extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var trees = [
	preload("res://assets/arvore1.png"),
	preload("res://assets/arvore2.png"),
	preload("res://assets/arvore3.png"),
]

func _ready() -> void:
	sprite_2d.texture = trees.pick_random()
