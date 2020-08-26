extends Position2D

func mouseReleased(dragging):
	var width = dragging.get_node("img").texture.get_width() * dragging.transform.get_scale().x
	var height = dragging.get_node("img").texture.get_height() * dragging.transform.get_scale().y
	if get_viewport().get_mouse_position().x > global_position.x - width/2 and get_viewport().get_mouse_position().x < global_position.x + width/2 and get_viewport().get_mouse_position().y > global_position.y - height/2 and get_viewport().get_mouse_position().y < global_position.y + height/2:
		if dragging.stats.value != 0 and dragging.stats.type != Master.cardTypes.monster and !dragging.inHand:
			if dragging.stats.type == Master.cardTypes.shield or dragging.stats.type == Master.cardTypes.sword or dragging.stats.type == Master.cardTypes.potion:
				dragging.dealer.useCoinItem(dragging)
#				dragging.dealer.runCoins += dragging.stats.value
#				dragging.dealer.updateLabel()
			if dragging.inBag:
				dragging.dealer.checkBeforeDestroy(dragging, true)
				get_parent().get_node("bag").free = true
			else:
				dragging.stats.value = 0
				dragging.dealer.sellCard(dragging)
