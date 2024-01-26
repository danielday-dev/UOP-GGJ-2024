extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal died(body)

@export var SPEED:float = 50
@export var momentumDampening:float = 40
@export var Attacks : Array[AttackInfo]
@export var minimumDistanceFromPlayer = 80
@export_category("Combat Stats")
@export var maxHealth: float = 3;

var children;
var currentHealth :float;
enum EnemyState{
	Grounded,
	Airborne,
	Attacking,
	Stunned,
	Prone,
	Dead,
	Anticipation,
	Cooldown,
}
var enemyState : EnemyState = EnemyState.Grounded

var activeAttack: AttackInfo;

var player : CharacterBody2D

func _ready():
	player = $/root/Main/Player
	currentHealth = maxHealth;
	children = get_children()

func _physics_process(delta):
	var movement : Vector2
	
	var distanceFromPlayer : float = ((global_position - player.global_position) * Vector2(1, 4)).length()
	
	if minimumDistanceFromPlayer <= distanceFromPlayer:
		movement = global_position.direction_to(player.global_position)
	else:
		movement = Vector2.ZERO
	var moveMultiplier : float = 0
	
	# enemy attacks player when in range of attack
	var jump :bool = false #########
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
						if (attack.anticipate):
							enemyState = EnemyState.Anticipation
						else:
							enemyState = EnemyState.Attacking
						activeAttack = attack;
						break
		EnemyState.Anticipation:
			setAnimation(activeAttack.animation + "Anti");
			if animationEnded():
				enemyState = EnemyState.Attacking
				
		EnemyState.Attacking:
			(get_node(activeAttack.hurtboxName) as Area2D).get_child(0).disabled = false;
			moveMultiplier = activeAttack.speedMulitplier;
			setAnimation(activeAttack.animation)
			
			if animationEnded():
				if (activeAttack.cooldown):
					enemyState = EnemyState.Cooldown
				else:
					enemyState = activeAttack.nextState as EnemyState;
				(get_node(activeAttack.hurtboxName) as Area2D).get_child(0).disabled = true
				
		EnemyState.Cooldown:
			setAnimation(activeAttack.animation + "Cool");
			if animationEnded():
				enemyState = activeAttack.nextState as EnemyState;
				
		EnemyState.Stunned:
			$EnemeyHitbox/HitboxCollider.disabled = true
			moveMultiplier = 0
			setAnimation("stunned")
			
			if animationEnded():
				enemyState = EnemyState.Grounded
				$EnemeyHitbox/HitboxCollider.disabled = false
		EnemyState.Prone:
			pass
	
	if (movement.x or movement.y) and moveMultiplier:
		velocity = movement * SPEED * moveMultiplier
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * momentumDampening)
		
	changeDirection(movement)
		
	move_and_slide()

func setAnimation(animation):
	if $Sprite.get_animation() != animation:
		$Sprite.play(animation)

func animationEnded():
	return $Sprite.frame_progress >= 1.0

var isFlipped : bool = false
func changeDirection(movement):
	var direction = sign(movement.x)
	var shouldBeFlipped :bool = direction == -1
	
	if direction and shouldBeFlipped != isFlipped:
		scale.x = -1
		isFlipped = shouldBeFlipped

func die():
	print("bazoogal the enemy died")
	died.emit(self)
	enemyState = EnemyState.Dead
	print("this is the part where he (the animation) kills you")
	for child in children:
		if child is Area2D:
			child.get_child(0).set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)
	setAnimation("dead")

func _on_enemy_hitbox_area_entered(area):
	print("steve the slime has had his ass slapped")
	currentHealth -= area.attackDamage
	if currentHealth <= 0:
		die()
