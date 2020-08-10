extends Area2D

onready var obj_name = get_node("name")
onready var obj_value = get_node("value")
var stats setget statsChanged

func statsChanged(_newStats):
	stats = _newStats
	stats.canMove = false
	$value.text = str(stats.life) + "/" + str(stats.maxLife)
	$name.text = stats.name
	$img.texture = load("res://Assets/Sprites/hero.png")

func _on_Card_input_event(viewport, event, shape_idx):
	pass
