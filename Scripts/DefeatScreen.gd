extends Node2D

func _ready():
	$CoinSprite/Coins.text = "+" + str(Master.lastRunCoins)

func _on_TouchScreenButton_released():
	Master.moveToScene("Menu")
