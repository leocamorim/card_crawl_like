extends Node

var path = "user://save.json"

var default_data = {
	"bgm": true,
	"coins": 0,
	"sfx": true
}

var data = {}

func _ready():
	loadGame()
	updateMaster()

func loadGame():
	var file = File.new()
	
	if not file.file_exists(path):
		resetData()
		return

	file.open(path, file.READ)

	var text = file.get_as_text()

	data = parse_json(text)

	file.close()

func resetData():
	data = default_data.duplicate(true)

func saveGame():
	var file = File.new()

	file.open(path, File.WRITE)
	
	data["bgm"] = Master.bgm
	data["coins"] = Master.coins
	data["sfx"] = Master.sfx

	file.store_line(to_json(data))

	file.close()

func updateMaster():
	Master.bgm = data["bgm"]
	Master.coins = data["coins"]
	Master.sfx = data["sfx"]
