extends CharacterBody2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var SPEED:float = 300
@export var momentumDampening:float = 40
@export var Attacks : Array[AttackInfo]

enum EnemyState{
	Grounded,
	Airborne,
	Attacking,
	Stunned,
	Prone,
}
var enemyState : EnemyState = EnemyState.Grounded

var activeAttack: AttackInfo;

var player : CharacterBody2D

func _ready():
	player = get_node("/root/Player")
	#player = get_tree().root.find_child("Player")

func _physics_process(delta):
	var distanceFromPlayer = position.distance_to(player.position)
	var movement : Vector2 = position.direction_to(player.position)
	var moveMultiplier = 0
	
	# enemy attacks player when in range of attack
	var jump :bool = true #########
	match enemyState:
		EnemyState.Grounded:
			moveMultiplier = 1
			
			if movement.x or movement.y:
				setAnimation("moving")
			else:
				setAnimation("idle")
				
			if jump:
				enemyState = EnemyState.Airborne
			else:
				for attack in Attacks:
					if distanceFromPlayer <= attack.range:
						enemyState = EnemyState.Attacking
						activeAttack = attack;						
						break
		EnemyState.Airborne:
			pass
		EnemyState.Attacking:
			(get_node(activeAttack.hurtboxName) as Area2D).monitorable = true;
			moveMultiplier = activeAttack.speedMulitplier;
			setAnimation(activeAttack.animation)
			
			if animationEnded():
				enemyState = activeAttack.nextState as EnemyState;
				(get_node(activeAttack.hurtboxName) as Area2D).monitorable = false
				
		EnemyState.Stunned:
			pass
		EnemyState.Prone:
			pass
	
	if (movement.x or movement.y) and moveMultiplier:
		velocity = movement * SPEED * moveMultiplier
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * momentumDampening)
		
	move_and_slide()

func setAnimation(animation):
	if $Sprite.get_animation() != animation:
		$Sprite.play(animation)

func animationEnded():
	return $Sprite.frame_progress >= 1.0
