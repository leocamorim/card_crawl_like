extends Node

var cardTypes = {
	sword = 1,
	shield = 2,
	potion = 3,
	coin = 4,
	monster = 5,
	special = 6,
	hero = 7
}

var colliderTypes = {
	player = "player",
	leftHand = "leftHand",
	rightHand = "rightHand",
	bag = "bag",
	card = "card",
	sellCard = "sellCard"
}

var deck = []
var sfx = true
var bgm = true
var isDragin = false
var coins = 0

func _ready():
	loadData()
	pass

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

func playAudio(_name, _type = "sfx"):
	if (_type == "sfx" and Master.sfx) or (_type == "bgm" and Master.bgm):
		var player = AudioStreamPlayer.new()
		self.add_child(player)
		player.stream = load('res://Assets/Audio/' + _name)
		player.play()
		yield(player, "finished")
		player.queue_free()

func loadData():
		# Load
	var f = File.new()
	f.open("res://Assets/Data/save.json", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	
	bgm = data["bgm"]
	coins = data["coins"]
	sfx = data["sfx"]

func saveData():
		# Load
	var f = File.new()
	f.open("res://Assets/Data/save.json", File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	var data = json.result
	
	# Modify
	data["sfx"] = sfx
	data["bgm"] = bgm
	data["coins"] = coins
	
	# Save
	f = File.new()
	f.open("res://Assets/Data/save.json", File.WRITE)
	f.store_string(JSON.print(data, "  ", true))
	f.close()
