extends Node2D

func _ready():
	Ss.loadGame()
	$Gold.text = str(Ss.data["coins"]) + " GOLD"
