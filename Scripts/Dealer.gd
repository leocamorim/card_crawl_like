extends Node

var cardList = []
var deck = {
	deckList = []
}
var table = []
var obj_player
var runCoins = 0

onready var pre_card = preload("res://Scenes/Card.tscn")
onready var pre_player = preload("res://Scenes/Player.tscn")
onready var pre_ticket = preload("res://Scenes/Ticket.tscn")

onready var animationHandler = $AnimationHandler

func _ready():
	Master.bgmChange("gameBgm.wav")
	randomize()
	loadPlayer()
	loadDeck()
	shuffleDeck()
	tableSetup()

func _process(delta):
	if !obj_player.get_node("AnimationPlayer").is_playing() and obj_player.stats.life <= 0 and canPlay():
		obj_player.get_node("AnimationPlayer").play("dead")
		Master.lastRunCoins = runCoins
		Ss.data.coins += Master.lastRunCoins
		Ss.saveGame()
		yield(obj_player.get_node("AnimationPlayer"), "animation_finished")
		Master.playAudio("defeat.ogg")
		Master.moveToScene("DefeatScreen")
	checkTable()
#	var aux = Engine.get_frames_per_second()
#	if aux != 60:
#		print(aux)

func draw():
	var drawingCard = deck.deckList.front()
	var tableTable = {
		sword = 0,
		shield = 0,
		potion = 0,
		coin = 0,
		monster = 0,
		special = 0,
		hero = 0,
	}
	if table.size() > 0:
		for card in table:
			if card.type == 1:
				tableTable.sword += 1
			if card.type == 2:
				tableTable.shield += 1
			if card.type == 3:
				tableTable.potion += 1
			if card.type == 4:
				tableTable.coin += 1
			if card.type == 5:
				tableTable.monster += 1
			if card.type == 6:
				tableTable.special += 1
			if card.type == 7:
				tableTable.hero += 1

	if ((drawingCard.type == Master.cardTypes.sword and tableTable.sword < 2) or deckHasOnly("sword")) or ((drawingCard.type == Master.cardTypes.shield and tableTable.shield < 2) or deckHasOnly("shield")) or ((drawingCard.type == Master.cardTypes.potion and tableTable.potion < 2) or deckHasOnly("potion")) or ((drawingCard.type == Master.cardTypes.coin and tableTable.coin < 2) or deckHasOnly("coin")) or ((drawingCard.type == Master.cardTypes.monster and tableTable.monster < 2) or deckHasOnly("monster")) or ((drawingCard.type == Master.cardTypes.special and tableTable.special < 2) or deckHasOnly("special")) or ((drawingCard.type == Master.cardTypes.hero and tableTable.hero < 2) or deckHasOnly("hero")):
		table.append(drawingCard)
		var new_card = pre_card.instance()
		new_card.visible = false
		new_card.stats = drawingCard
		var _childCounter = 0
		for slot in $table.get_children():
			if slot.get_child_count() == 0:
				slot.add_child(new_card)
				_childCounter = $table.get_child_count()
		deck.deckList.pop_front()
		updateLabel()
		new_card.get_node("AnimationPlayer").play("fadeIn")
		return new_card
	else:
		shuffleDeck()
		return draw()

func canPlay():
	if !$Timer.is_stopped():
		return false
	if $AnimationHandler.visible == true:
		return false
	for slot in $table.get_children():
		if slot.get_children().size() > 0:
			if !slot.get_children()[0].is_in_group("ticket") and slot.get_children()[0].get_node("AnimationPlayer").is_playing():
				return false
	if obj_player.get_node("AnimationPlayer").is_playing() or $AnimationPlayer.is_playing():
		return false
	return true

func deckHasOnly(_type):
	for card in deck.deckList:
		if card.type != Master.cardTypes[_type]:
			return false
	return true

func checkTable():
	if deck.deckList.size() > 0 and table.size() == 1 and canPlay() and $Timer.is_stopped():
		clearTable()
		$Timer.start(1)
		yield($Timer, "timeout")
		while(deck.deckList.size() > 0 and table.size() < 4):
			var new_card = draw()
			yield(new_card.get_node("AnimationPlayer"), "animation_finished")
	elif table.size() <= 0:
		if obj_player.stats.life > 0:
			Master.lastRunCoins = runCoins
			Ss.data.coins += Master.lastRunCoins
			Ss.saveGame()
			Master.moveToScene("WinScreen")

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
			var new_card = draw()
			yield(new_card.get_node("AnimationPlayer"), "animation_finished")

func updateLabel():
	$Gold.text = str(runCoins) + " GOLD"
	$DeckLabel.text = str(deck.deckList.size())


func shuffleDeck():
	randomize()
	deck.deckList.shuffle()

func loadDeck():
	cardList = Master.readJSON("cardDB")
	Master.decks.shuffle()
	deck = Master.readJSON(Master.decks[0])
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
	$player.add_child(obj_player)
	obj_player.position = Vector2()
	obj_player.stats = stats
	obj_player.show_behind_parent = true

func _on_Draw_released():
	draw()

func _on_Discard_released():
	if(table.size() > 0):
		pass

func monsterAttackPlayer(monster):
	animationHandler.visible = true
	animationHandler.global_position = $player.global_position
	animationHandler.frame = 0
	animationHandler.play("damage")
	Master.playAudio("highMonsAttack.wav")
#	if monster.stats.value >= 6:
#	else:
#		Master.playAudio("lowMonsAttack.wav")
	yield(animationHandler, "animation_finished")
	animationHandler.visible = false
	obj_player.get_node("AnimationPlayer").play("receiveDmg")
	yield(obj_player.get_node("AnimationPlayer"), "animation_finished")
	obj_player.stats.life -= monster.stats.value
	popTicket("-" + str(monster.stats.value))
	monster.stats.value = 0
	removeFromTable(monster)

func sellCard(card):
	removeFromTable(card, true)

func usePotionItem(item):
	$AnimationPlayer.play("heal")
	Master.playAudio("heartbeat.wav")
	yield($AnimationPlayer, "animation_finished")
	Master.playAudio("afterHeal.wav")
	obj_player.stats.life += item.stats.value
	if obj_player.stats.life > obj_player.stats.maxLife:
		popTicket("+" + str(item.stats.value - (obj_player.stats.life - obj_player.stats.maxLife)))
		obj_player.stats.life = obj_player.stats.maxLife
	else:
		popTicket("+" + str(item.stats.value))
	item.stats.value = 0

func useCoinItem(item):
	Master.playAudio("coin.wav")
	runCoins += item.stats.value
	item.stats.value = 0
	updateLabel()

func checkBeforeDestroy(card, clear = false):
	if card.stats.value <= 0:
		var anim = card.get_node("AnimationPlayer")
		anim.play("fadeOut")
		yield(anim, "animation_finished")
		if  card.inHand or card.inBag:
			card.get_parent().free = true
		elif card.stats.type == Master.cardTypes.monster:
			removeFromTable(card)
		if clear or (card.stats.type != Master.cardTypes.monster and card.stats.type != Master.cardTypes.coin and card.stats.type != Master.cardTypes.potion):
			card.get_parent().remove_child(card)

func removeFromTable(card, sell = false):
	if !sell and card.stats.type != Master.cardTypes.monster:
		checkBeforeDestroy(card)
	else:
		var anim = card.get_node("AnimationPlayer")
		anim.play("fadeOut")
		yield(anim, "animation_finished")
	if card.get_parent().get_parent() == $table:
		card.get_parent().remove_child(card)
		var index = -1
		for item in table:
				index += 1
				if(item.id == card.stats.id):
					table.remove(index)
					break

func popTicket(text, parent = obj_player):
	parent = parent.get_parent()
	var _ticket = pre_ticket.instance()
	parent.add_child(_ticket)
	_ticket.scale = Vector2(2, 2)
	_ticket.global_position = parent.global_position
	_ticket.setText(text)
