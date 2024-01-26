extends TextureButton


func _onPressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
