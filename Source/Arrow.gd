extends Sprite2D

var canFlash : bool =true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _encounterStart():
	hide()
	canFlash = false

func _encounterEnd():
	canFlash = true

func _on_arrow_timer_timeout():
	if canFlash:
		if visible:
			hide()
		else:
			show()
