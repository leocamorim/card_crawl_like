extends Node

var path = "user://save.json"

var default_data = {
	"bgm": true,
	"coins": 0,
	"sfx": true
}

var data = {}

func hasSave():
	var file = File.new()
	
	if file.file_exists(path):
		return true
	else:
		return false

func loadGame():
	var file = File.new()
	
	if not file.file_exists(path):
		Master.isTutorial = true
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
	
	data["bgm"] = data["bgm"]
	data["coins"] = data["coins"]
	data["sfx"] = data["sfx"]

	file.store_line(to_json(data))

	file.close()
