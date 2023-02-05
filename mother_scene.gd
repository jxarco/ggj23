extends Node3D

var scene = preload("res://Scene.tscn")
var scene_instanced

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_instanced = scene.instantiate()
	scene_instanced.reset.connect(_on_node_3d_reset)
	add_child(scene_instanced)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_node_3d_reset():
	scene_instanced.queue_free()
	scene_instanced = scene.instantiate()
	scene_instanced.reset.connect(_on_node_3d_reset)
	add_child(scene_instanced)
	pass # Replace with function body.
