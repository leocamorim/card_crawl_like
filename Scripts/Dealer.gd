extends Node

var cardList = []
var deck = {
	deckList = []
}
var table = []
var obj_player
var isPalying = true
var winCondition = false

var minDifficultyCoeficient = 13
var maxDifficultyCoeficient = 13

onready var pre_card = preload("res://Scenes/Card.tscn")
onready var pre_player = preload("res://Scenes/Player.tscn")

func _ready():
	randomize()
	loadPlayer()
	loadDeck()
	shuffleDeck()
	tableSetup()

func _process(delta):
	if obj_player.stats.life <= 0 and isPalying:
#		isPalying = false
#		Master.playAudio("defeat.ogg")
		Master.moveToScene("DefeatScreen")
	checkTable()
	var aux = Engine.get_frames_per_second()
	if aux != 60:
		print(aux)

func draw():
	print("draw new card")
	if table.size() < 4 and deck.deckList.size() > 0:
		var drawingCard = deck.deckList.front()
		table.append(drawingCard)
		var new_card = pre_card.instance()
		new_card.canMove = true
		new_card.stats = drawingCard
		var _childCounter = 0
		for slot in $table.get_children():
			if slot.get_child_count() == 0:
				print("PARENT")
				print(new_card.get_parent())
				slot.add_child(new_card)
				_childCounter = $table.get_child_count()
		deck.deckList.pop_front()
		updateLabel()

func checkTable():
	if deck.deckList.size() > 0 and table.size() == 1:
		clearTable()
		while(deck.deckList.size() > 0 and table.size() < 4):
			draw()
	elif table.size() <= 0:
		if obj_player.stats.life > 0:
			print("YOU WIN")
			Master.moveToScene("WinScreen")
		else:
			Master.moveToScene("DefeatScreen")

func clearTable():
	for card in $bag.get_children():
		if card.is_in_group("card"):
			if card.stats.value <= 0:
				checkBeforeDestroy(card, true)
				$bag.free = true
	for card in $rightHand.get_children():
		if card.is_in_group("card"):
			if card.stats.value <= 0:
				checkBeforeDestroy(card, true)
				$rightHand.free = true
	for card in $leftHand.get_children():
		if card.is_in_group("card"):
			if card.stats.value <= 0:
				checkBeforeDestroy(card, true)
				$leftHand.free = true

func tableSetup():	
	var outOfTableSlots = [Master.colliderTypes.rightHand, Master.colliderTypes.leftHand, Master.colliderTypes.bag]
	if table.size() <= 1:
		for slot in outOfTableSlots:
			for item in get_node(slot).get_children():
				if(item.has_method("_on_Card_area_entered")):
					checkBeforeDestroy(item)
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
	removeFromTable(monster)

func useBattleItem(item, monster):
	var originalValues = {
		item = int(item.stats.value),
		monster = int(monster.stats.value)
	}
	monster.stats.value -= originalValues.item
	if(item.stats.type == Master.cardTypes.sword):
		item.stats.value = 0
		checkBeforeDestroy(monster)
	elif(item.stats.type == Master.cardTypes.shield):
		item.stats.value -= originalValues.monster
		if(monster.stats.value > 0):
			monsterAttackPlayer(monster)
		else:
			checkBeforeDestroy(monster)
	checkBeforeDestroy(item)

func sellCard(card):
	removeFromTable(card, true)
#	checkBeforeDestroy(card)

func usePotionItem(item):
	obj_player.stats.life += item.stats.value
	if obj_player.stats.life > obj_player.stats.maxLife:
		obj_player.stats.life = obj_player.stats.maxLife
	item.stats.value = 0
#	removeFromTable(item)

func useCoinItem(item):
	Master.coins += item.stats.value
	item.stats.value = 0
#	removeFromTable(item)
	print("Total Coins: "+str(Master.coins))

func checkBeforeDestroy(card, clear = false):
	if card.stats.value <= 0:
		if  card.inHand or card.inBag:
			card.get_parent().free = true
		elif card.stats.type == Master.cardTypes.monster:
			removeFromTable(card)
		if clear or (card.stats.type != Master.cardTypes.monster and card.stats.type != Master.cardTypes.coin and card.stats.type != Master.cardTypes.potion):
			card.get_parent().remove_child(card)

func removeFromTable(card, sell = false):
	if card.get_parent().get_parent() == $table:
		card.get_parent().remove_child(card)
		var index = -1
		for item in table:
				index += 1
				if(item.id == card.stats.id):
					table.remove(index)
	if !sell and card.stats.type != Master.cardTypes.monster:
		checkBeforeDestroy(card)
