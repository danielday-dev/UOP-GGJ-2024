extends CharacterBody2D


@export var SPEED: float = 300.0;
@export var momentumDampening :float = 40;


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * momentumDampening)

	var uppydowner = Input.get_axis("move_up", "move_down")
	if uppydowner:
		velocity.y = uppydowner * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED * delta * momentumDampening)
		
	move_and_slide()
