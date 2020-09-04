extends Node2D

func _ready():
	Ss.loadGame()
	if !Ss.hasSave():
		Master.isTutorial = true
		Master.moveToScene("InGame")
	$Gold.text = str(Ss.data["coins"]) + " GOLD"
	Master.bgmChange("menuBgm.wav")
