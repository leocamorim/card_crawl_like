extends Node2D

func _ready():
	$Gold.text = str(Master.coins) + " GOLD"
