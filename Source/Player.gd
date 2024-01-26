extends CharacterBody2D


@export var SPEED: float = 300.0;
@export var momentumDampening :float = 40;
@export_category("Combat Stats")
@export var maxHealth: float = 6;
var currentHealth :float
@export var beansHeal : float = 2;
@export var numBeans : int = 3;

signal damageTaken(currentHealth)
signal beanUsed(currentBeans)

var lastHitTimer = 0;

enum PlayerState{
	Grounded,
	Airborne,
	Dodging,
	Attacking,
	Stunned,
	Prone,
	Dead,

	Anticipation,
	Cooldown,
}
var playerState : PlayerState = PlayerState.Grounded

func _ready():
	currentHealth = maxHealth;

enum AttackType{
	Light,
	Heavy,
	Beans,
}
var attackType : AttackType = AttackType.Beans
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	var moveMultiplier: float = 0
	
	if (lastHitTimer > 0):
		lastHitTimer -= delta;
	
	
	var movement : Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	var attack1: bool = Input.is_action_pressed("attack1");
	var attack2: bool = Input.is_action_pressed("attack2")
	var dodge : bool = Input.is_action_pressed("dodge");
	var beans : bool = Input.is_action_pressed("beans");
	var jump : bool = Input.is_action_pressed("jump");
	
	match playerState:
		PlayerState.Grounded:
			moveMultiplier = 1
			if movement.x or movement.y:
				setAnimation("moving")
			else:
				setAnimation("idle")
				
			if attack1:
				playerState = PlayerState.Attacking
				attackType = AttackType.Light
			elif attack2:
				playerState = PlayerState.Anticipation
				attackType = AttackType.Heavy
			elif dodge:
				playerState = PlayerState.Dodging
			elif beans:
				if numBeans > 0 && currentHealth < maxHealth:
					numBeans -= 1
					beanUsed.emit(numBeans)
					currentHealth = clamp(currentHealth + 2, 0, maxHealth);
					damageTaken.emit(currentHealth)
					playerState = PlayerState.Attacking
					attackType = AttackType.Beans
			elif jump:
				playerState = PlayerState.Airborne
			changeDirection(movement)
			
		PlayerState.Dodging:
			$Hitbox/HitboxCollider.disabled = true
			moveMultiplier = 1.5
			setAnimation("dodge")
			
			changeDirection(movement)
			
			if animationEnded():
				playerState = PlayerState.Grounded
				$Hitbox/HitboxCollider.disabled = false
			
		PlayerState.Anticipation:
			setAnimation("featherHeavyAnticipation")
			if animationEnded():
				playerState = PlayerState.Attacking;
	
		PlayerState.Attacking:
			match attackType:
				AttackType.Light:
					moveMultiplier = 0.6
					$LightFeatherHurtbox/HurtboxCollider.disabled = false
					setAnimation("featherLight")
					
				AttackType.Heavy:
					moveMultiplier = 0.4
					$HeavyFeatherHurtbox/HurtboxCollider.disabled = false
					setAnimation("featherHeavy")
					
				AttackType.Beans:
					moveMultiplier = 0.1
					setAnimation("beans")
					
			if animationEnded():
				playerState = PlayerState.Grounded
				$LightFeatherHurtbox/HurtboxCollider.disabled = true
				$HeavyFeatherHurtbox/HurtboxCollider.disabled = true
				
		PlayerState.Stunned:
			$Hitbox/HitboxCollider.disabled = true
			moveMultiplier = 0
			setAnimation("stunned")
			
			if animationEnded():
				playerState = PlayerState.Grounded
				$Hitbox/HitboxCollider.disabled = false
	
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

var isFlipped : bool = false
func changeDirection(movement):
	var direction = sign(movement.x)
	var shouldBeFlipped :bool = direction == -1
	
	if direction and shouldBeFlipped != isFlipped:
		scale.x = -1
		isFlipped = shouldBeFlipped 

func _on_hitbox_area_entered(area):
	if (lastHitTimer <= 0) :
		currentHealth -= area.attackDamage
		damageTaken.emit(currentHealth)
		playerState = PlayerState.Stunned
		lastHitTimer = 0.3
		if currentHealth <= 0:
			die()

func die_defer():
	get_tree().change_scene_to_file("res://Scenes/LoseScreen.tscn");
	

func die():
	playerState = PlayerState.Dead
	call_deferred("die_defer")

func _on_win_game_body_entered(body):
	get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn");
