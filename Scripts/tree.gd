extends RigidBody3D
@export
var max_health = 2
var health
var is_fallen = false
var is_cleaned = false

var tree_holder

func _ready():
	health = max_health
	var tree_parent = get_parent().get_parent()
	if(tree_parent.name == "Forest"):
		tree_holder = tree_parent.get_node("TreeHolder")

func _process(delta):
	pass

func _physics_process(delta):
	pass
	
func get_hit(damage):
	if!is_fallen:
		health -= damage
		if(health <= 0):
			is_fallen = true
			freeze = false
			apply_impulse(Vector3(50, 1, 0), Vector3(0, 0, 0))
			health = max_health/2
	elif !is_cleaned:
		health -= damage
		if(health <= 0):
			get_node("TreeModel").visible = false
			is_cleaned= true;
			$FallTimer.start()
			
func _on_freeze_timer_timeout():
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC


func _on_fall_timer_timeout():
	GM.get_instance().increment_felled_trees()
	queue_free()
	tree_holder.instantiate_tree()
