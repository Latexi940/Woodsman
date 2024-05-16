extends Node3D

const FOREST_SCENE_PATH = "res://Scenes/forest.tscn"
var entered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_log_sign()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(entered):
		get_tree().change_scene_to_file(FOREST_SCENE_PATH)

func _on_forest_gate_area_3d_body_entered(body):
	if body.name == "Player":
		entered = true;
		

func _update_log_sign():
	get_node("LogSign/LogLabel").text = str(GM.felled_trees)
