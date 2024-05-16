extends Node3D

@export
var tree_amount = 2000
@export
var rock_amount = 400
var spawn_area_min = Vector3(-250, 0, -250)
var spawn_area_max = Vector3(250, 0, 250)
var clear_area_min = Vector3(-4, 0, 250)
var clear_area_max = Vector3(4, 0, 250)
const tree_spacing = 3
const random_offset = 1

const HOME_SCENE_PATH = "res://Scenes/home.tscn"
var entered = false
var tree_scene = preload("res://Scenes/tree.tscn")
var rock_scene = preload("res://Scenes/rock.tscn")

func _ready():
	generate_world()

func _process(delta):
	if(entered):
		get_tree().change_scene_to_file(HOME_SCENE_PATH)
	
func generate_world():
	var woods = get_node("Woods")
	#add forest edge trees
	for x in range(spawn_area_min.x, spawn_area_max.x, tree_spacing):
		add_tree(Vector3(x, 0, spawn_area_min.z), randf_range(0, 360),generate_random_tree_size(4), true)
		add_tree(Vector3(x, 0, spawn_area_max.z), randf_range(0, 360),generate_random_tree_size(4), true)
	for z in range(spawn_area_min.z, spawn_area_max.z, tree_spacing):
		add_tree(Vector3(spawn_area_min.x, 0, z), randf_range(0, 360),generate_random_tree_size(4), true)
		add_tree(Vector3(spawn_area_max.x, 0, z), randf_range(0, 360),generate_random_tree_size(4), true)

	#add random rocks
	for i in range(rock_amount):
		var random_position = generate_random_position()
		while overlaps_existing_objects(random_position):
			random_position = generate_random_position()
		var rock_instance = rock_scene.instantiate()
		var random_rotation = randf_range(0, 360)
		var random_height = randf_range(rock_instance.scale.y -0.2, rock_instance.scale.y +0.2)
		var random_width = randf_range(rock_instance.scale.x -0.2, rock_instance.scale.x +0.2)
		var random_depth = randf_range(rock_instance.scale.z -0.2, rock_instance.scale.z +0.2)
		var new_size = Vector3(random_width, random_height, random_depth)
		rock_instance.transform.origin = random_position
		rock_instance.rotate_y(random_rotation)
		rock_instance.scale = new_size
		woods.add_child(rock_instance)
		
	#add random trees
	for i in range(tree_amount):
		var random_position = generate_random_position()
		while overlaps_existing_objects(random_position):
			random_position = generate_random_position()
		var tree_instance = tree_scene.instantiate()
		var random_rotation = randf_range(0, 360)
		var random_height = randf_range(tree_instance.scale.y -0.2, tree_instance.scale.y +0.2)
		var random_width = randf_range(tree_instance.scale.x -0.2, tree_instance.scale.x +0.2)
		var random_depth = randf_range(tree_instance.scale.z -0.2, tree_instance.scale.z +0.2)
		var new_size = Vector3(random_width, random_height, random_depth)
		add_tree(random_position,random_rotation,new_size, false)
		
func add_tree(posi, rota, size, is_edge_tree):
	if(is_in_clear_area(posi)):
		return
	var tree_instance = tree_scene.instantiate()
	var woods = get_node("Woods")
	tree_instance.transform.origin = posi
	tree_instance.rotate_y(rota)
	tree_instance.scale = size
	if(is_edge_tree):
		tree_instance.max_health = 99999
	woods.add_child(tree_instance)
		
func generate_random_position() -> Vector3:
	return Vector3(
		randf_range(spawn_area_min.x, spawn_area_max.x),
		0,
		randf_range(spawn_area_min.z, spawn_area_max.z)
	)
func generate_random_tree_size(multiplier) -> Vector3:
	var tree_instance = tree_scene.instantiate()
	var random_height = randf_range(tree_instance.scale.y -0.2, tree_instance.scale.y +0.2)
	var random_width = randf_range(tree_instance.scale.x -0.2, tree_instance.scale.x +0.2)
	var random_depth = randf_range(tree_instance.scale.z -0.2, tree_instance.scale.z +0.2)
	var new_size = Vector3(random_width * multiplier, random_height * multiplier, random_depth * multiplier)
	return new_size
	
func is_in_clear_area(position):
	return position.x >= clear_area_min.x and position.x <= clear_area_max.x and position.z >= clear_area_min.z and position.z <= clear_area_max.z

func overlaps_existing_objects(position: Vector3) -> bool:
	for tree_instance in get_tree().get_nodes_in_group("Trees"):
		if tree_instance.global_transform.origin.distance_to(position) < 1.0:
			return true
	for world_object in get_tree().get_nodes_in_group("WorldObject"):
		if world_object.global_transform.origin.distance_to(position) < 4:
			return true
	for world_object in get_tree().get_nodes_in_group("Rock"):
		if world_object.global_transform.origin.distance_to(position) < 0.5:
			return true

	var player_character = get_node("Player")
	if player_character and player_character.global_transform.origin.distance_to(position) < 2.5: 
		return true

	return false


func _on_home_gate_area_3d_body_entered(body):
	if body.name == "Player":
		entered = true;
