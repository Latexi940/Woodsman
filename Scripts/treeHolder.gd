extends Node3D

var tree_scene = preload("res://Scenes/tree.tscn")

func _ready():
	pass

func _process(delta):
	pass

func instantiate_tree():
	var tree_instance = tree_scene.instantiate()
	tree_instance.freeze = false
	
	var random_x = randf_range(-1.5, 1.5)
	
	var current_translation = tree_instance.position
	tree_instance.position = Vector3(random_x, 3, -3.5)
	tree_instance.rotation_degrees.x = 90
	tree_instance.get_node("TreeModel").visible = false
	var timer = tree_instance.get_node("FreezeTimer")
	add_child(tree_instance)
	timer.start()

