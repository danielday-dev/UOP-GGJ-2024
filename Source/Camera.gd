extends Camera2D

@export var followTarget : Node2D;
@export var followOffset : Vector2 = Vector2.ZERO;
@export_range(0.01, 10) var followStrength : float = 1;

func _physics_process(delta):
	if (followTarget):
		position = lerp(position, followTarget.position + followOffset, followStrength * delta);
