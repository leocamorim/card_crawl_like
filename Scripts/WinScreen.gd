extends Node2D

var localCoins = 0

func _ready():
	Master.bgmChange()
	$CoinSprite/Coins.text = "+" + str(localCoins)

func _process(delta):
	if localCoins < Master.lastRunCoins:
		localCoins += 1
		$CoinSprite/Coins.text = "+" + str(localCoins)
	else:
		set_process(false)

func _on_TouchScreenButton_released():
	Master.moveToScene("Menu")
