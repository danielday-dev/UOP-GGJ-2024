extends Resource
class_name CutsceneInformation

@export var targetNode : NodePath = ""
@export var targetFrom : Vector2 = Vector2(0.5, 0.5);
@export var targetTo : Vector2 = Vector2(0.5, 0.5);
@export var cutsceneTime : float = 1;
@export_range(0, 1) var zoomLevel : float = 1;
