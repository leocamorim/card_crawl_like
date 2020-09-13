extends Node

var cardList = []
var deck = {
	deckList = [],
	specialDeckList = []
}
var table = []
var obj_player
var runCoins = 0
var runDrawed = 0

onready var pre_card = preload("res://Scenes/Components/Card.tscn")
onready var pre_player = preload("res://Scenes/Components/Player.tscn")
onready var pre_ticket = preload("res://Scenes/Components/Ticket.tscn")

onready var animationHandler = $AnimationHandler

signal written
signal clicked
signal procceed

var tutorialStep = 0

func _ready():
	Master.bgmChange("gameBgm.wav")
	randomize()
	if Master.isTutorial:
		playTutorial()
	else:
		$boss.modulate.a = 1
		loadDeck()
		writeChat(str(Master.deck.name) + "\n" + str(Master.deck.desc))
		loadPlayer()
		shuffleDeck()
		tableSetup()
	$AnimationPlayer.stop(true)

func _process(delta):
	if !Master.isTutorial:
		if obj_player != null and !obj_player.get_node("AnimationPlayer").is_playing() and obj_player.stats.life <= 0 and canPlay():
			obj_player.get_node("AnimationPlayer").play("dead")
			yield(obj_player.get_node("AnimationPlayer"), "animation_finished")
			Master.playAudio("defeat.wav")
			Master.moveToScene("DefeatScreen")
	checkTable()
	if Master.isTutorial and Input.is_action_just_pressed("click"):
		emit_signal("clicked")
	if tutorialStep == 1:
		if $rightHand.get_child_count() > 0 or $leftHand.get_child_count() > 0:
			emit_signal("procceed")
	elif tutorialStep == 2:
		if obj_player.stats.life < 13:
			emit_signal("procceed")
	elif tutorialStep == 3:
		if obj_player.stats.life >= 13:
			emit_signal("procceed")
	elif tutorialStep == 4:
		if $rightHand.get_child_count() > 0 or $leftHand.get_child_count() > 0:
			emit_signal("procceed")
	elif tutorialStep == 5:
		if table.size() <= 0 and deck.deckList.size() <= 0:
			emit_signal("procceed")
		elif obj_player.stats.life <= 0:
			Master.isTutorial = false
			Master.moveToScene("DefeatScreen")
#	var aux = Engine.get_frames_per_second()
#	if aux != 60:
#		print(aux)

func playTutorial():
	if !Ss.hasSave():
		$BtClose.visible = false
		$SellLabel.visible = false
	$SellLabel.text = "Quit"
	$boss.visible = false
	$sell.visible = false
	$ClickSignal.visible = false
	$Gold.visible = false

	writeChat("Click anywhere to begin tutorial!")
	yield(self, "written")

	$AnimationPlayer.play("clickSignal")
	yield(self, "clicked")
	Master.playAudio("button.wav")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false
	$ClickSignal.text = "Click to continue..."

	loadPlayer()
	obj_player.get_node("AnimationPlayer").play_backwards("dead")
	yield(obj_player.get_node("AnimationPlayer"), "animation_finished")

	writeChat("That handsome guy down there is you.\nIn card souls, your goal is simple:\n empty the dealer's souls deck without becoming a soul.")
	yield(self, "written")

	$AnimationPlayer.play("clickSignal")
	yield(self, "clicked")
	Master.playAudio("button.wav")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false

	$AnimationPlayer.play("bossFadeIn")
	yield($AnimationPlayer, "animation_finished")

	writeChat("But it's not as easy as it seems...\nThe Dealer has the strongest deck in all Hraesvelgr.\nFull of powerful monsters.")
	yield(self, "written")

	$AnimationPlayer.play("clickSignal")
	yield(self, "clicked")
	Master.playAudio("button.wav")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false

	loadDeck(true)
	tableSetup()
	$Timer.start(3)
	yield($Timer, "timeout")

	writeChat("What a bad luck! A monster on the first hand! Grab that shield and put it in your hand before that monster attacks you!")
	yield(self, "written")
	
	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card") and card.stats.type == Master.cardTypes["shield"]:
				card.canMove = true

	tutorialStep = 1

	$ClickSignal.text = "Drag the shield to any of your hands"
	$AnimationPlayer.play("clickSignal")
	yield(self, "procceed")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false

	tutorialStep = 2

	writeChat("Good! Now you can defend yourself from that monster's attack.")
	yield(self, "written")
	
	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card") and card.stats.type == Master.cardTypes["monster"]:
				card.canMove = true

	$ClickSignal.text = "Drag the monster to attack your shield"
	$AnimationPlayer.play("clickSignal")
	yield(self, "procceed")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false

	tutorialStep = 3

	writeChat("Oh no! You are hurt!\nI guess that monster was too strong...\nDrink that potion to heal your wounds!")
	yield(self, "written")

	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card") and card.stats.type == Master.cardTypes["potion"]:
				card.canMove = true

	$ClickSignal.text = "Drag the potion to your hand to use it"
	$AnimationPlayer.play("clickSignal")
	yield(self, "procceed")
	$AnimationPlayer.stop(true)
	$ClickSignal.visible = false
	
	tutorialStep = 4

	writeChat("OH NO!\nAS HIS LAST CARD HE DRAWED HIMSELF!\nGRAB THAT SWORD AND ATTACK HIM TO WIN THIS MATCH!")
	yield(self, "written")

	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card") and card.stats.type == Master.cardTypes["sword"]:
				card.canMove = true
			else:
				card.canMove = false

	$ClickSignal.text = "Win this match"
	$AnimationPlayer.play("clickSignal")
	yield(self, "procceed")

	clearTable()
	tutorialStep = 5

	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card") and card.stats.type == Master.cardTypes["monster"]:
				card.canMove = true

	yield(self, "procceed")

	if !Ss.hasSave():
		Master.lastRunCoins = 50
		Ss.data["coins"] += Master.lastRunCoins
		Ss.saveGame()
	else:
		Master.lastRunCoins = 0
	Master.isTutorial = false
	Master.playAudio("victory.wav", -5)
	Master.moveToScene("WinScreen")

func writeChat(_text):
	$Chat.visible = true
	$Chat.text = _text
	if _text != "":
		for i in range(0, _text.length()):
			$Chat.visible_characters = i
			yield(get_tree().create_timer(0.025), "timeout")
		emit_signal("written")

func draw():
	var drawingCard = deck.deckList.front()
	if runDrawed > 0 and runDrawed % 10 == 9 and deck.specialDeckList.size() > 0:
		drawingCard = deck.specialDeckList.front()
	var tableTable = {
		holdable = 0,
		potion = 0,
		coin = 0,
		monster = 0,
		special = 0,
		hero = 0,
	}
	if table.size() > 0:
		for card in table:
			if card.type == 1 or card.type == 2:
				tableTable.holdable += 1
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

#	if $rightHand.get_children().size() > 0:
#		for card in $rightHand.get_children():
#			if card.is_in_group("card"):
#				if card.stats.type == 1 or card.stats.type == 2:
#					tableTable.holdable += 1
#				if card.stats.type == 3:
#					tableTable.potion += 1
#				if card.stats.type == 4:
#					tableTable.coin += 1
#				if card.stats.type == 5:
#					tableTable.monster += 1
#				if card.stats.type == 6:
#					tableTable.special += 1
#				if card.stats.type == 7:
#					tableTable.hero += 1
#
#	if $leftHand.get_children().size() > 0:
#		for card in $leftHand.get_children():
#			if card.is_in_group("card"):
#				if card.stats.type == 1 or card.stats.type == 2:
#					tableTable.holdable += 1
#				if card.stats.type == 3:
#					tableTable.potion += 1
#				if card.stats.type == 4:
#					tableTable.coin += 1
#				if card.stats.type == 5:
#					tableTable.monster += 1
#				if card.stats.type == 6:
#					tableTable.special += 1
#				if card.stats.type == 7:
#					tableTable.hero += 1

	if $bag.get_children().size() > 0:
		for card in $bag.get_children():
			if card.is_in_group("card"):
				if card.stats.type == 1 or card.stats.type == 2:
					tableTable.holdable += 1
				if card.stats.type == 3:
					tableTable.potion += 1
				if card.stats.type == 4:
					tableTable.coin += 1
				if card.stats.type == 5:
					tableTable.monster += 1
				if card.stats.type == 6:
					tableTable.special += 1
				if card.stats.type == 7:
					tableTable.hero += 1

	if drawingCard.type == Master.cardTypes.special:
		table.append(drawingCard)
		var new_card = pre_card.instance()
		new_card.visible = false
		new_card.stats = drawingCard
		if Master.isTutorial:
			new_card.canMove = false
		var _childCounter = 0
		for slot in $table.get_children():
			if slot.get_child_count() == 0:
				slot.add_child(new_card)
				_childCounter = $table.get_child_count()
		deck.specialDeckList.pop_front()
		updateLabel()
		new_card.get_node("AnimationPlayer").play("fadeIn")
		Master.playAudio("draw.wav")
		runDrawed += 1
		print("Drawed card number " + str(runDrawed) + " and it was " + drawingCard.name)
		return new_card
	else:
		if (((drawingCard.type == Master.cardTypes.sword or drawingCard.type == Master.cardTypes.shield) and tableTable.holdable < 2) or deckHasOnly("holdable")) or ((drawingCard.type == Master.cardTypes.potion and tableTable.potion < 2) or deckHasOnly("potion")) or ((drawingCard.type == Master.cardTypes.coin and tableTable.coin < 2) or deckHasOnly("coin")) or ((drawingCard.type == Master.cardTypes.monster and tableTable.monster < 2) or deckHasOnly("monster")) or ((drawingCard.type == Master.cardTypes.special and tableTable.special < 2) or deckHasOnly("special")) or ((drawingCard.type == Master.cardTypes.hero and tableTable.hero < 2) or deckHasOnly("hero")):
	#	if (((drawingCard.type == Master.cardTypes.sword or drawingCard.type == Master.cardTypes.shield) and tableTable.holdable < 2)) or ((drawingCard.type == Master.cardTypes.potion and tableTable.potion < 2)) or ((drawingCard.type == Master.cardTypes.coin and tableTable.coin < 2)) or ((drawingCard.type == Master.cardTypes.monster and tableTable.monster < 2)) or ((drawingCard.type == Master.cardTypes.special and tableTable.special < 2)) or ((drawingCard.type == Master.cardTypes.hero and tableTable.hero < 2)) or deckHasOnly2(tableTable):
			table.append(drawingCard)
			var new_card = pre_card.instance()
			new_card.visible = false
			new_card.stats = drawingCard
			if Master.isTutorial:
				new_card.canMove = false
				if new_card.stats.value == 10:
					new_card.stats.value = 15
				if new_card.stats.value == 7:
					new_card.stats.value = 15
			var _childCounter = 0
			for slot in $table.get_children():
				if slot.get_child_count() == 0:
	#				if new_card.get_parent() != null:
	#					new_card.get_parent().remove_child(new_card)
					slot.add_child(new_card)
					_childCounter = $table.get_child_count()
			deck.deckList.pop_front()
			updateLabel()
			new_card.get_node("AnimationPlayer").play("fadeIn")
			Master.playAudio("draw.wav")
			runDrawed += 1
			print("Drawed card number " + str(runDrawed))
			return new_card
		else:
			shuffleDeck()
			return draw()

func canPlay():
	if Master.isTutorial:
		return true
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

func deckHasOnly2(_tableCount):
	var _aux = []
	if _tableCount.holdable >= 2:
		_aux.append("holdable")
	if _tableCount.potion >= 2:
		_aux.append("potion")
	if _tableCount.coin >= 2:
		_aux.append("coin")
	if _tableCount.monster >= 2:
		_aux.append("monster")
	if _tableCount.special >= 2:
		_aux.append("special")
	if _tableCount.hero >= 2:
		_aux.append("hero")

	var _counter = 0
	for type in _aux:
		if deckHasOnly(type):
			_counter += 1

	return !(_counter == _aux.size())

func deckHasOnly(_type):
	for card in deck.deckList:
		if _type != "holdable":
			if card.type != Master.cardTypes[_type]:
				return false
		else:
			if card.type != Master.cardTypes["sword"] and card.type != Master.cardTypes["shield"]:
				return false
	return true

func checkTable():
	if (deck.deckList.size() > 0 or deck.specialDeckList.size() > 0) and table.size() <= 1 and canPlay() and $Timer.is_stopped():
		clearTable()
		if !Master.isTutorial:
			$Timer.start(1)
		else:
			$Timer.start(1.6)
		yield($Timer, "timeout")
		while((deck.deckList.size() > 0 or deck.specialDeckList.size() > 0) and table.size() < 4):
			var new_card = draw()
			yield(new_card.get_node("AnimationPlayer"), "animation_finished")
	elif deck.deckList.size() <= 0 and deck.specialDeckList.size() <= 0 and !Master.isTutorial and table.size() <= 0:
		if obj_player != null and obj_player.stats.life > 0:
			Master.lastRunCoins = runCoins
			Ss.data.coins += Master.lastRunCoins
			Ss.saveGame()
			Master.playAudio("victory.wav", -5)
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
	if table.size() <= 1:
		while table.size() < 4 and (deck.deckList.size() > 0 or deck.specialDeckList.size() > 0):
			var new_card = draw()
			yield(new_card.get_node("AnimationPlayer"), "animation_finished")

func updateLabel():
	$Gold.text = str(runCoins) + " GOLD"
	$DeckLabel.text = str(deck.deckList.size() + deck.specialDeckList.size())

func shuffleDeck():
	randomize()
	deck.deckList.shuffle()
	deck.specialDeckList.shuffle()

func loadDeck(_isTutorial = false):
	cardList = Master.readJSON("cardDB")
	Master.decks.shuffle()
	if _isTutorial:
		deck = Master.readJSON("tutorialDeck")
	else:
		deck = Master.readJSON(Master.decks[0])
	var _deckList = [];
	var _specialDeckList = [];
	for cardId in deck.deckList:
		for card in cardList:
			if(card.id == cardId):
				_deckList.append(card.duplicate())
	for cardId in deck.specialDeckList:
		for card in cardList:
			if(card.id == cardId):
				_specialDeckList.append(card.duplicate())
	deck.deckList = _deckList;
	deck.specialDeckList = _specialDeckList;
#	cardList = [];
	Master.deck = deck

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
	obj_player.get_node("AnimationPlayer").play_backwards("dead")

func monsterAttackPlayer(monster):
	animationHandler.visible = true
	animationHandler.global_position = $player.global_position
	animationHandler.frame = 0
	animationHandler.play("damage")
#if monster.stats.value >= 6:
	Master.playAudio("highMonsAttack.wav")
#else:
#	Master.playAudio("lowMonsAttack.wav")
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
	Master.playAudio("heartbeat.wav", 10)
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
			if card.get_parent().has_method("free"):
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

func reDraw():
	for slot in $table.get_children():
		for card in slot.get_children():
			if card.is_in_group("card"):
				deck.deckList.append(card.stats.duplicate())
				removeFromTable(card, true)
				var anim = card.get_node("AnimationPlayer")
				anim.play("fadeOut")
				updateLabel()
				yield(anim, "animation_finished")

func _on_BtClose_pressed():
	Master.isTutorial = false
	Master.moveToScene("Menu")
