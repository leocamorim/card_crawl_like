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

func mouseReleased(using):
#	print("mouseReleased")
	var width = $img.texture.get_width() * transform.get_scale().x
	var height = $img.texture.get_height() * transform.get_scale().y
	if get_viewport().get_mouse_position().x > global_position.x - width/2 and get_viewport().get_mouse_position().x < global_position.x + width/2 and get_viewport().get_mouse_position().y > global_position.y - height/2 and get_viewport().get_mouse_position().y < global_position.y + height/2:
#		print("ON THE PLAYER")
		using.useOnPlayer()
