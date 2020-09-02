extends Area2D

onready var obj_name = get_node("name")
onready var obj_value = get_node("value")
onready var dealer = get_parent().get_parent().get_parent()
onready var overlay = $overlay
var dragMouse = false
var stats setget statsChanged
var safePosition = Vector2(0,0)
var colliding
var collidingGroup
var inHand = false
var inBag = false

func _process(delta):
	if dragMouse and dealer.canPlay():
		set_z_index(10)
		set_global_position(get_viewport().get_mouse_position())
	else:
		set_z_index(0)

func _on_Card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and dealer.canPlay():
			safePosition = global_position
			dragMouse = true
			Master.isDragin = true
			Master.playAudio("drag.wav")
		elif dragMouse: 
			dragMouse = false
			Master.isDragin = false
			onRelease()
#			Master.playAudio("release.wav")

func onRelease():
	get_tree().call_group("card", "mouseReleased", self)
	get_tree().call_group("player", "mouseReleased", self)
	get_tree().call_group("hand", "mouseReleased", self)
	get_tree().call_group("bag", "mouseReleased", self)
	get_tree().call_group("sellCard", "mouseReleased", self)

func mouseReleased(dragging):
	if dragging != self:
		var width = $img.texture.get_width() * transform.get_scale().x
		var height = $img.texture.get_height() * transform.get_scale().y
		if get_viewport().get_mouse_position().x > global_position.x - width/2 and get_viewport().get_mouse_position().x < global_position.x + width/2 and get_viewport().get_mouse_position().y > global_position.y - height/2 and get_viewport().get_mouse_position().y < global_position.y + height/2:
			if dragging.inHand and stats.type == Master.cardTypes.monster and dragging.stats.type == Master.cardTypes.sword:
				swordOnMonster(dragging)
			if inHand and stats.type == Master.cardTypes.shield and dragging.stats.type == Master.cardTypes.monster:
				monsterOnShield(dragging)
	else:
		set_global_position(safePosition)

func useOnPlayer():
	if stats.type == Master.cardTypes.monster:
		dealer.monsterAttackPlayer(self)
	else:
		set_global_position(safePosition)

func swordOnMonster(_sword, _monster = self):
	dealer.animationHandler.visible = true
	dealer.animationHandler.global_position = global_position
	dealer.animationHandler.frame = 0
	dealer.animationHandler.play("damage")
	Master.playAudio("sword.wav")
	yield(dealer.animationHandler, "animation_finished")
	dealer.animationHandler.visible = false
	$AnimationPlayer.play("receiveDmg")
	yield($AnimationPlayer, "animation_finished")
	_monster.stats.value -= _sword.stats.value
	dealer.popTicket("-" + str(_sword.stats.value), _monster)
	_sword.stats.value = 0
	dealer.checkBeforeDestroy(_sword)
	if _monster.stats.value <= 0:
		dealer.checkBeforeDestroy(_monster)

func monsterOnShield(_monster, _shield = self):
	dealer.animationHandler.visible = true
	dealer.animationHandler.global_position = global_position
	dealer.animationHandler.frame = 0
	dealer.animationHandler.play("damage")
	Master.playAudio("shield.wav")
	if _monster.stats.value > _shield.stats.value:
		Master.playAudio("highMonsAttack.wav")
	yield(dealer.animationHandler, "animation_finished")
	if _monster.stats.value > _shield.stats.value:
		dealer.animationHandler.visible = true
		dealer.animationHandler.global_position = dealer.obj_player.global_position
		dealer.animationHandler.frame = 0
		dealer.animationHandler.play("damage")
		dealer.obj_player.get_node("AnimationPlayer").play("receiveDmg")
		_shield.get_node("AnimationPlayer").play("receiveDmg")
		yield(dealer.obj_player.get_node("AnimationPlayer"), "animation_finished")
		dealer.popTicket("-" + str(_monster.stats.value - _shield.stats.value))
		dealer.popTicket("-" + str(_shield.stats.value), _shield)
		dealer.obj_player.stats.life -= _monster.stats.value - _shield.stats.value
		_shield.stats.value = 0
	elif _shield.stats.value >= _monster.stats.value:
		_shield.get_node("AnimationPlayer").play("receiveDmg")
		yield(_shield.get_node("AnimationPlayer"), "animation_finished")
		_shield.stats.value -= _monster.stats.value
		dealer.popTicket("-" + str(_monster.stats.value), _shield)
	dealer.animationHandler.visible = false
	_monster.stats.value = 0
	dealer.removeFromTable(_monster)
	dealer.checkBeforeDestroy(_shield)

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
	if overlay != null:
		if stats.value <= 0:
			overlay.visible = true
		else:
			overlay.visible = false
