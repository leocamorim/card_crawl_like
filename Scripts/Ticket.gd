extends Node2D

func _ready():
	$AnimationPlayer.play("lifetime")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func setText(_text):
	$Label.text = _text
