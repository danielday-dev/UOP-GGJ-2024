extends Camera2D

@export var camera_speed: int = 300
var camera_direction: int = 0;
var camera_locked: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !camera_locked:
		position.x += camera_direction * camera_speed * delta

func _on_right_border_body_entered(body):
	camera_direction += 1
func _on_right_border_body_exited(body):
	camera_direction -= 1
func _on_left_border_body_entered(body):
	camera_direction -= 1
func _on_left_border_body_exited(body):
	camera_direction += 1
func _on_arrow_timer_timeout():
	if !camera_locked and $GIANTORANGEARROW.is_visible():
		$GIANTORANGEARROW.hide()
	else:
		$GIANTORANGEARROW.show()
