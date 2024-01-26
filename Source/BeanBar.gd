extends HBoxContainer

func _update_bean(current_bean):
	var loopCount = 0
	
	for heart in get_children():
		if current_bean >= loopCount + 1:
			heart.setAnimation("full")
		else:
			heart.setAnimation("empty")
		loopCount += 1
