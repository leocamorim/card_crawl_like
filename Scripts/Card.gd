extends Area2D

onready var obj_name = get_node("name")
onready var obj_value = get_node("value")
var canMove = false
var dragMouse = false
var stats setget statsChanged
var safePosition = Vector2(0,0)
var colliding
var collidingGroup
var inHand = false
var inBag = false
var isUsed = false
var dealer

func _ready():
	dealer = get_parent().get_parent().get_parent()

func _process(delta):
	if dragMouse and canMove:
		set_global_position(get_viewport().get_mouse_position())

func _on_Card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and canMove:
			safePosition = global_position
			dragMouse = true
			Master.isDragin = true
		elif dragMouse: 
			dragMouse = false
			Master.isDragin = false
			onRelease()

func onRelease():
	if not inHand:
		if collidingGroup == Master.colliderTypes.player:
			if stats.type == Master.cardTypes.monster:
				dealer.monsterAttackPlayer(self)
			else:
				set_global_position(safePosition)
		elif collidingGroup == Master.colliderTypes.rightHand or collidingGroup == Master.colliderTypes.leftHand:
			if stats.type != Master.cardTypes.monster and dealer.get_node(collidingGroup).free == true:
				if(inBag):
					self.get_parent().free = true
					inBag = false
				inHand = true
				call_deferred("reparent", dealer.get_node(collidingGroup))
				dealer.get_node(collidingGroup).stats = stats
				dealer.get_node(collidingGroup).free = false
				if stats.type == Master.cardTypes.potion:
					dealer.usePotionItem(self)
				if stats.type == Master.cardTypes.coin:
					print("b@*$# better have my money!")
					dealer.useCoinItem(self)
			else:
				set_global_position(safePosition)
		elif not inBag:
			if collidingGroup == Master.colliderTypes.bag:
				if stats.type != Master.cardTypes.monster and dealer.get_node(collidingGroup).free == true:
					inBag = true
					call_deferred("reparent", dealer.get_node(collidingGroup))
					dealer.get_node(collidingGroup).stats = stats
					dealer.get_node(collidingGroup).free = false
					if stats.type == Master.cardTypes.coin:
						print("b@*$# better have my money!")
						dealer.useCoinItem(self)
				else:
					set_global_position(safePosition)
			elif collidingGroup == Master.colliderTypes.sellCard:
				if(stats.type != Master.cardTypes.monster):
					print("Selling card!")
					dealer.sellCard(self)
				else:
					set_global_position(safePosition)
			elif stats.type == Master.cardTypes.monster and colliding.inHand and (colliding.stats.type == Master.cardTypes.sword or colliding.stats.type == Master.cardTypes.shield):
				dealer.useBattleItem(colliding, self)
			else:
				set_global_position(safePosition)
		else:
			set_global_position(safePosition)
	else:
		if collidingGroup == Master.colliderTypes.card:
			if stats.type != Master.cardTypes.monster:
				if (stats.type == Master.cardTypes.sword or stats.type == Master.cardTypes.shield) and colliding.stats.type == Master.cardTypes.monster:
					dealer.useBattleItem(self, colliding)
		set_global_position(safePosition)
	dealer.tableSetup()

func reparent(new_parent):
	dealer.table.remove(dealer.table.find(self.stats))
	self.get_parent().remove_child(self)
	new_parent.add_child(self)
	new_parent.get_children()[1].set_global_position(new_parent.global_position)
	dealer.tableSetup()

func statsChanged(_newStats):
	stats = _newStats
	if stats.type != Master.cardTypes.hero:
		$name.text = stats.name
		$img.texture = load("res://Assets/Sprites/" + str(Master.getTypeName(stats.type)) + "-" + str(stats.id) + ".png")
		$value.text = str(stats.value)
	else:
		$value.text = str(stats.life) + "/" + str(stats.maxLife)
		$name.text = stats.name
		$img.texture = load("res://Assets/Sprites/hero.png")

func _on_Card_area_entered(area):
	colliding = area
	if area.is_in_group("player"):
		collidingGroup = Master.colliderTypes.player
	elif area.is_in_group("hand"):
		collidingGroup = Master.colliderTypes[area.name]
	elif area.is_in_group("bag"):
		collidingGroup = Master.colliderTypes.bag
	elif area.is_in_group("card"):
		collidingGroup = Master.colliderTypes.card
	elif area.is_in_group("sellCard"):
		collidingGroup = Master.colliderTypes.sellCard
	else:
		collidingGroup = Master.getTypeName(area.stats.type)
	pass

func _on_Card_area_exited(area):
#	if (collidingGroup == Master.colliderTypes.player and area.is_in_group("player")) or ((collidingGroup == Master.colliderTypes.leftHand or collidingGroup == Master.colliderTypes.rightHand) and area.is_in_group("hand")):
	colliding == null
	pass
