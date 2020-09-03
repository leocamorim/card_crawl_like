extends Node

var decks = ["deck1"]

var cardTypes = {
	sword = 1,
	shield = 2,
	potion = 3,
	coin = 4,
	monster = 5,
	special = 6,
	hero = 7
}

var deck = []
var isDragin = false
var lastRunCoins = 0

var bgmAudio

func _ready():
	Ss.loadGame()
	playAudio("menuBgm.wav", 0, "bgm")

func moveToScene(sceneName):
	get_tree().change_scene("res://Scenes/"+sceneName+".tscn")

func readJSON(name):
	var data_file = File.new()
	if data_file.open("res://Assets/Data/"+name+".json", File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	return data

func getTypeName(_int):
	for key in cardTypes.keys():
		if _int == cardTypes[key]:
			return key

func playAudio(_name, _volume = 0, _type = "sfx"):
	if (_type == "sfx" and Ss.data["sfx"]) or (_type == "bgm" and Ss.data["bgm"]):
		var player = AudioStreamPlayer.new()
		self.add_child(player)
		player.stream = load('res://Assets/Audio/' + _name)
		if _volume:
			player.volume_db = _volume
		player.play()
		if _type == "bgm":
			if bgmAudio and bgmAudio.playing:
				bgmAudio.queue_free()
			bgmAudio = player
			yield(player, "finished")
			bgmAudio.stop()
		else:
			yield(player, "finished")
			player.queue_free()

func bgmChange(_keep = ""):
	if _keep == "":
		if bgmAudio:
			bgmAudio.emit_signal("finished")
	else:
		if bgmAudio:
			if bgmAudio.stream.resource_path != "res://Assets/Audio/" + _keep:
				bgmAudio.emit_signal("finished")
				playAudio(_keep, 0, "bgm")
		else:
			playAudio(_keep, 0, "bgm")
