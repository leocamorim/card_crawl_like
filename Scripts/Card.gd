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
			print("dragged")
			safePosition = global_position
			dragMouse = true
			Master.isDragin = true
		elif dragMouse: 
			dragMouse = false
			Master.isDragin = false
			onRelease()

func onRelease():
	get_tree().call_group("card", "mouseReleased", self)
	get_tree().call_group("player", "mouseReleased", self)
	get_tree().call_group("hand", "mouseReleased", self)
	get_tree().call_group("bag", "mouseReleased", self)
	get_tree().call_group("sellCard", "mouseReleased", self)
	pass

func mouseReleased(dragging):
	if dragging != self:
		var width = $img.texture.get_width() * transform.get_scale().x
		var height = $img.texture.get_height() * transform.get_scale().y
		if get_viewport().get_mouse_position().x > global_position.x - width/2 and get_viewport().get_mouse_position().x < global_position.x + width/2 and get_viewport().get_mouse_position().y > global_position.y - height/2 and get_viewport().get_mouse_position().y < global_position.y + height/2:
			if stats.type == Master.cardTypes.monster and dragging.stats.type == Master.cardTypes.sword:
				print("attacking monster")
				swordOnMonster(dragging)
				pass
			if stats.type == Master.cardTypes.shield and dragging.stats.type == Master.cardTypes.monster:
				print("monster attacking shield")
				monsterOnShield(dragging)
				pass
	else:
		set_global_position(safePosition)

func useOnPlayer():
	if stats.type == Master.cardTypes.monster:
		dealer.monsterAttackPlayer(self)
	else:
		set_global_position(safePosition)

func swordOnMonster(_sword, _monster = self):
	_monster.stats.value -= _sword.stats.value
	_sword.stats.value = 0
	if _monster.stats.value <= 0:
		dealer.checkBeforeDestroy(_monster)
	dealer.checkBeforeDestroy(_sword)

func monsterOnShield(_monster, _shield = self):
	if _monster.stats.value > _shield.stats.value:
		dealer.obj_player.stats.life -= _monster.stats.value - _shield.stats.value
		_shield.stats.value = 0
	elif _shield.stats.value >= _monster.stats.value:
		_shield.stats.value -= _monster.stats.value
	_monster.stats.value = 0
	dealer.removeFromTable(_monster)
	dealer.checkBeforeDestroy(_shield)
	pass

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
