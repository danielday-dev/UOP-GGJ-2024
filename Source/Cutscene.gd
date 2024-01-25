extends Camera2D

@export var cutscenes : Array[CutsceneInformation];
@export_file("*.tscn") var nextScene : String;

var progress : float = 0;

func _process(delta):
	# Change scene at end.
	if (len(cutscenes) <= 0):
		get_tree().change_scene_to_file(nextScene);
		return;
		
	# Get cutscene.
	var cutscene = cutscenes[0];	
	if (progress < cutscene.cutsceneTime):
		# Update progress.
		progress = clamp(progress + delta, 0, cutscene.cutsceneTime);
		
		# This code sucks but i dont regret anything.
		var sprite = get_node(cutscene.targetNode);
		var spriteSize = Vector2(
			sprite.texture.get_width(), 
			sprite.texture.get_height()
		) * sprite.scale;
		
		# Lerpy derp.
		position = sprite.position + (lerp(cutscene.targetFrom, cutscene.targetTo, progress / cutscene.cutsceneTime) * spriteSize);	
		zoom.x = 1 / cutscene.zoomLevel;
		zoom.y = zoom.x;
	
		if (progress >= cutscene.cutsceneTime):
			cutscenes.remove_at(0);
			progress = 0;
