extends Sprite2D

@export var followTarget : Camera2D;
@export_range(0, 1) var followRate : float = 1;

var followOffset : float = 0;

func _ready():
	followOffset = position.x;
	

func _process(delta):
	if (followTarget):
		# Move to pos.
		position.x = (followTarget.position.x * followRate) + followOffset
