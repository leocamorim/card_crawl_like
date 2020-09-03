extends Position2D

var free = true

func mouseReleased(dragging):
	var width = dragging.get_node("img").texture.get_width() * dragging.transform.get_scale().x
	var height = dragging.get_node("img").texture.get_height() * dragging.transform.get_scale().y
	if get_viewport().get_mouse_position().x > global_position.x - width/2 and get_viewport().get_mouse_position().x < global_position.x + width/2 and get_viewport().get_mouse_position().y > global_position.y - height/2 and get_viewport().get_mouse_position().y < global_position.y + height/2:
		if free and dragging.stats.type != Master.cardTypes.monster and !dragging.inHand:
			free = false
			dragging.inHand = true
			if dragging.inBag:
				dragging.get_parent().remove_child(dragging)
				get_tree().call_group("bag", "set_free", self)
			else:
				dragging.dealer.removeFromTable(dragging)
			add_child(dragging)
			dragging.safePosition = global_position
			dragging.global_position = dragging.safePosition
			if dragging.inBag:
				get_tree().call_group("bag", "set_free")
				dragging.inBag == false
			if dragging.stats.type == Master.cardTypes.potion:
				dragging.dealer.usePotionItem(dragging)
			elif dragging.stats.type == Master.cardTypes.coin:
				dragging.dealer.useCoinItem(dragging)
			else:
				Master.playAudio("pickUp.wav", 10)
