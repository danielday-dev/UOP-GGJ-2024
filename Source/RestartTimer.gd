extends Node2D

@export var countdownMax = 120;
var currentCountdown;

func _ready(): 
	# Initiate countdown.
	currentCountdown = countdownMax;

func _process(_delta):
	if (Input.is_anything_pressed()): 
		# Change scene.
		currentCountdown = countdownMax;
		return;
		
	if (currentCountdown < 30):
		# Show label + text.
		$Panel/Label.text = "Auto-refresh never hurt anyone,\n This game will return to menu in " + str(currentCountdown) + " seconds";				
		$Panel.show();		
	else:
		# Hide label.
		$Panel.hide();		

func _onTimeout():
	# Decrement countdown.
	currentCountdown -= 1;
	if (currentCountdown <= 0):
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
