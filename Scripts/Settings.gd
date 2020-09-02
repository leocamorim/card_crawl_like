extends Node

onready var pre_switchOn = preload("res://Assets/Hud/switchOn.png")
onready var pre_switchOff = preload("res://Assets/Hud/switchOff.png")

func _ready():
	Ss.loadGame()
	updateSwitches()

func _on_bgm_switch_released():
	Ss.data["bgm"] = !Ss.data["bgm"]
	Ss.saveGame()
	updateSwitches()
	if Ss.data["bgm"]:
		Master.playAudio("menuBgm.wav", "bgm")
	else:
		Master.bgmChange()

func _on_sfx_switch_released():
	Ss.data["sfx"] = !Ss.data["sfx"]
	Ss.saveGame()
	updateSwitches()

func updateSwitches():
	if Ss.data["bgm"]:
		get_parent().get_node("bgm_switch").normal = pre_switchOn
	else:
		get_parent().get_node("bgm_switch").normal = pre_switchOff

	if Ss.data["sfx"]:
		get_parent().get_node("sfx_switch").normal = pre_switchOn
	else:
		get_parent().get_node("sfx_switch").normal = pre_switchOff

func _on_BtBack_pressed():
	get_parent().get_node("BtBack/Label").rect_position.y += 30

func _on_BtBack_released():
	Master.moveToScene("Menu")
