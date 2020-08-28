extends Node2D

func _ready():
	Master.loadData()
	$Gold.text = str(Master.coins) + " GOLD"
