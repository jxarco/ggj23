extends Node3D

var scene = preload("res://Scene.tscn")
var scene_instanced

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	scene_instanced = scene.instantiate()
	scene_instanced.reset_game.connect(_on_node_3d_reset)
	add_child(scene_instanced)

func _input(event):
	if event.is_action_pressed("Exit"):
		get_tree().quit()

func _on_node_3d_reset():
	
	scene_instanced.queue_free()
	scene_instanced = scene.instantiate()
	scene_instanced.reset_game.connect(_on_node_3d_reset)
	add_child(scene_instanced)
	
	World.state.reset()	
