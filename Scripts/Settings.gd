extends Control

func _ready():
	if !Master.bgm:
		Master.bgm = false
		$bgm/label_bgm.modulate.a = 0.5
		$bgm/audioOn.visible = false
	if !Master.sfx:
		Master.sfx = false
		$sfx/label_sfx.modulate.a = 0.5
		$sfx/audioOn.visible = false
	pass

func _on_bgm_button_up():
	print("upped")
	if Master.bgm:
		Master.bgm = false
		$bgm/label_bgm.modulate.a = 0.5
		$bgm/audioOn.visible = false
	else:
		Master.bgm = true
		$bgm/label_bgm.modulate.a = 1
		$bgm/audioOn.visible = true
	Master.saveData()

func _on_sfx_button_up():
	print("upped")
	if Master.sfx:
		Master.sfx = false
		$sfx/label_sfx.modulate.a = 0.5
		$sfx/audioOn.visible = false
	else:
		Master.sfx = true
		$sfx/label_sfx.modulate.a = 1
		$sfx/audioOn.visible = true
	Master.saveData()

func _on_exit_button_up():
	Master.moveToScene("Menu")
