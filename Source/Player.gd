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

enum PlayerState{
	Grounded,
	Airborne,
	Dodging,
	Attacking,
	Stunned,
	Prone,
	Dead,
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
				playerState = PlayerState.Attacking
				attackType = AttackType.Heavy
			elif dodge:
				playerState = PlayerState.Dodging
			elif beans:
				if numBeans > 0:
					numBeans -= 1
					beanUsed.emit(numBeans)
					currentHealth += 2
					damageTaken.emit(currentHealth)
					playerState = PlayerState.Attacking
					attackType = AttackType.Beans
			elif jump:
				playerState = PlayerState.Airborne
			changeDirection(movement)
		PlayerState.Airborne:
			pass
		PlayerState.Dodging:
			$Hitbox.monitorable = false
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
			pass
		PlayerState.Prone:
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

var isFlipped : bool = false
func changeDirection(movement):
	var direction = sign(movement.x)
	var shouldBeFlipped :bool = direction == -1
	
	if direction and shouldBeFlipped != isFlipped:
		scale.x = -1
		isFlipped = shouldBeFlipped 

func _on_hitbox_area_entered(area):
	print("player has been hit uwu")
	currentHealth -= area.attackDamage
	damageTaken.emit(currentHealth)
	print(currentHealth)
	if currentHealth <= 0:
		die()

func die():
	print("easy mode is now available")
	playerState = PlayerState.Dead
	get_tree().change_scene_to_file("res://Scenes/loseScreen.tscn");


func _on_win_game_body_entered(body):
	get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn");
