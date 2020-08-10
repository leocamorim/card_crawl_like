extends Node

var cardList = []
var deck = {
	deckList = []
}
var table = []
var obj_player
var isPalying = true

onready var pre_card = preload("res://Scenes/Card.tscn")
onready var pre_player = preload("res://Scenes/Player.tscn")

func _ready():
	randomize()
	loadPlayer()
	loadDeck()
	shuffleDeck()
	tableSetup()

# warning-ignore:unused_argument
func _process(delta):
	if obj_player.stats.life <= 0 and isPalying:
#		isPalying = false
#		Master.playAudio("defeat.ogg")
		Master.moveToScene("Menu")

func draw():
	if table.size() < 4 and deck.deckList.size() > 0:
		var drawingCard = deck.deckList.front()
		table.append(drawingCard)
		var new_card = pre_card.instance()
		new_card.canMove = true
		new_card.stats = drawingCard
		var _childCounter = 0
		while (_childCounter < $table.get_child_count()):
			var slot = $table.get_children()[_childCounter]
			if slot.get_child_count() == 0:
				slot.add_child(new_card)
				_childCounter = $table.get_child_count()
			_childCounter += 1
		deck.deckList.pop_front()
		updateLabel()

func tableSetup():	
	var outOfTableSlots = [Master.colliderTypes.rightHand, Master.colliderTypes.leftHand, Master.colliderTypes.bag]
	if table.size() <= 1:
		for slot in outOfTableSlots:
			for item in get_node(slot).get_children():
				if(item.has_method("_on_Card_area_entered")):
					checkBeforeDestroy(item, false)
		while table.size() < 4 and deck.deckList.size() > 0:
			draw()

func updateLabel():
	$Label.text = ""
	$DeckLabel.text = str(deck.deckList.size())
	for card in table:
		$Label.text += str(card.name)+" "+str(card.value)+"\n"

func shuffleDeck():
	randomize()
	deck.deckList.shuffle()

func loadDeck():
	cardList = Master.readJSON("cardDB")
	deck = Master.readJSON("deck")
	var deckList = [];
	for card in cardList:
		for cardId in deck.deckList:
			if(card.id == cardId):
				deckList.append(card.duplicate())
	deck.deckList = deckList;
	cardList = [];

func loadPlayer():
	var stats = {
		leftHand = {},
		rightHand = {},
		bag = {},
		maxLife = 13,
		name = "The Hero"
	}
	stats.life = stats.maxLife
	obj_player = pre_player.instance()
	obj_player.position = Vector2(420, 1450)
	obj_player.stats = stats
	add_child(obj_player)

func _on_Draw_released():
	draw()

func _on_Discard_released():
	if(table.size() > 0):
		pass

func monsterAttackPlayer(monster):
	obj_player.stats.life -= monster.stats.value
	monster.stats.value = 0
	checkBeforeDestroy(monster, true)

func useBattleItem(item, monster):
	var originalValues = {
		item = int(item.stats.value),
		monster = int(monster.stats.value)
	}
	monster.stats.value -= originalValues.item
	if(item.stats.type == Master.cardTypes.sword):
		item.stats.value = 0
		checkBeforeDestroy(monster, true)
	elif(item.stats.type == Master.cardTypes.shield):
		item.stats.value -= originalValues.monster
		if(monster.stats.value > 0):
			monsterAttackPlayer(monster)
		else:
			checkBeforeDestroy(monster, true)
	checkBeforeDestroy(item, false)

func sellCard(card):
	useCoinItem(card)
	checkBeforeDestroy(card, true)

func usePotionItem(item):
	obj_player.stats.life += item.stats.value
	if obj_player.stats.life > obj_player.stats.maxLife:
		obj_player.stats.life = obj_player.stats.maxLife
	item.stats.value = 0

func useCoinItem(item):
	Master.coins += item.stats.value
	item.stats.value = 0
	print("Total Coins: "+str(Master.coins))

func checkBeforeDestroy(card, isOnTable):
	var index = -1
	if(card.stats.value <= 0):
		for item in table:
			index += 1
			if(item.id == card.stats.id):
				table.remove(index)
		if !isOnTable:
			card.get_parent().free = true
			card.get_parent().stats = null
		card.get_parent().remove_child(card)
