extends HBoxContainer


func _update_health(current_health):
	var loopCount = 0
	
	for heart in get_children():
		if current_health >= loopCount + 2:
			heart.setAnimation("full")
		elif current_health >= loopCount + 1:
			heart.setAnimation("half")
		else:
			heart.setAnimation("empty")
		loopCount += 2
