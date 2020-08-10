extends Node2D

func _on_bt_start_released():
	Master.moveToScene("InGame")

func _on_bt_config_released():
	Master.moveToScene("Components/Settings")

func _on_bt_desc_released():
	print("CREDITS START")
