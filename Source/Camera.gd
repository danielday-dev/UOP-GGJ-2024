extends Camera2D

@export var followTarget : Node2D;
@export var followOffset : Vector2 = Vector2.ZERO;

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if (followTarget):
		#position = lerp(position, followTarget.position + followOffset, followStrength * delta);
		position = followTarget.position + followOffset
		
		var x = zoom.x * (screen_size.x / 2);
		position.x = clamp(position.x, limit_left + x, limit_right - x);
		
		var y = zoom.y * (screen_size.y / 2);
		position.y = clamp(position.y, limit_top + y, limit_bottom - y);
		
func changeRightLimit(newLimit:float):
	limit_right = max(newLimit, limit_right)
