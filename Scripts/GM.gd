#GM.gd

extends Node

var instance
var felled_trees = 0

func _ready():
	assert(instance == null)
	instance = self

func _process(delta):
	pass

func increment_felled_trees():
	felled_trees += 1

func get_felled_trees():
	return felled_trees
	

func get_instance():
	if instance == null:
		instance = GM.new()
	return instance
