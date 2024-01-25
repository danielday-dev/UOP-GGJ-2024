extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal died(body)

@export var SPEED:float = 50
@export var momentumDampening:float = 40
@export var Attacks : Array[AttackInfo]
@export var minimumDistanceFromPlayer = 80
@export_category("Combat Stats")
@export var maxHealth: float = 100;

var currentHealth :float = maxHealth;
enum EnemyState{
	Grounded,
	Airborne,
	Attacking,
	Stunned,
	Prone,
	Dead,
}
var enemyState : EnemyState = EnemyState.Grounded

var activeAttack: AttackInfo;

var player : CharacterBody2D

func _ready():
	player = $/root/Main/Player
	for attack in Attacks:
		var attackNode = get_node(attack.hurtboxName)
		attackNode.attackDamage = attack.damage

func _physics_process(delta):
	var movement : Vector2
	
	var distanceFromPlayer : float = ((position - player.position) * Vector2(1, 4)).length()
	
	if minimumDistanceFromPlayer <= distanceFromPlayer:
		movement = position.direction_to(player.position)
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
	died.emit()
	enemyState = EnemyState.Dead


func _on_enemy_hitbox_area_entered(area):
	currentHealth -= area.attackDamage
	if currentHealth <= 0:
		die()
