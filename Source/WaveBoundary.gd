extends Area2D



@export var cameraClampLocationX : float = 0
@export var graveyard : Node2D

@export var cameraXLimit : float = 0

signal limitCameraMovement(cameraXLimit)


var children
# Called when the node enters the scene tree for the first time.
func _ready():
	children = get_children()
	for child in children:
		if !(child is Timer) and !(child is CollisionShape2D):
			child.hide()
			child.set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	limitCameraMovement.emit()
	var tim = get_child(1)
	tim.start()

func _on_mob_spawn_timer_timeout():
	for child in children:
		if !(child is Timer) and !child.visible:
			child.set_process(true)
			child.show()
			break;

func playerHasDefeatedEnemies():
	limitCameraMovement.emit()
			
func checkAllWavesClear():
	for child in children:
		if child.get_child_count() != 0:
			return
	playerHasDefeatedEnemies()

func enemyHasDied(body):
	body.reparent(graveyard)
	checkAllWavesClear()
