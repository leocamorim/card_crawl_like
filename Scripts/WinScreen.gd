extends Node2D

func _ready():
	Master.bgmChange()
	$CoinSprite/Coins.text = "+" + str(Master.lastRunCoins)

func _on_TouchScreenButton_released():
	Master.moveToScene("Menu")
