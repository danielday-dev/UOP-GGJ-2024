extends Sprite2D

@export var followTarget : Camera2D;
@export_range(0, 1) var followRate : float = 1;

var followOffset : float = 0;

func _ready():
	followOffset = position.x;

func _process(delta):
	if (followTarget):
		# Get clamped pos.
		var t = followTarget.position;
		var x = followTarget.zoom.x * (640 / 2);
		t.x = clamp(t.x, followTarget.limit_left + x, followTarget.limit_right - x);
		
		# Move to pos.
		position.x = (t.x * followRate) + followOffset
