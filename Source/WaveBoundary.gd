extends Area2D

@export var graveyard : Node2D

@export var cameraXLimit : float = 0

signal limitCameraMovement(cameraXLimit)
signal encounterStarted
var encounterStartedEmitted : bool = false;
signal encounterEnded

var children
# Called when the node enters the scene tree for the first time.
func _ready():
	children = get_children()
	
	for child in children:
		if !(child is Timer) and !(child is CollisionShape2D):
			child.hide()
			for kid in child.get_children():
				kid.set_physics_process(false)
				kid.died.connect(enemyHasDied)
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if !encounterStartedEmitted:
		var tim = get_child(1)
		tim.start()
		encounterStarted.emit()
		encounterStartedEmitted = true
		print("nice body (im picking you up)")

func _on_mob_spawn_timer_timeout():
	for child in children:
		if !(child is Timer) and !child.visible:
			for kid in child.get_children():
				kid.set_physics_process(true)
			child.show()
			break;

func playerHasDefeatedEnemies():
	limitCameraMovement.emit(cameraXLimit)
	encounterEnded.emit()
	
			
func checkAllWavesClear():
	for child in children:
		if child.get_child_count() != 0:
			return
	playerHasDefeatedEnemies()

func enemyHasDied(body):
	body.call_deferred("reparent", graveyard)
	call_deferred("checkAllWavesClear")
