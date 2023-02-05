extends Node3D

var waterway_steps : int = 3
var current_step : int = waterway_steps

var wet_material = preload("res://level_scenes/waterway/waterway_wet_mat.tres")
var wet_texture  = preload("res://assets/gfx/suelo_humedo.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_wet():
	%waterway_0.get_active_material(0).albedo_texture = wet_texture
	%waterway_1.get_active_material(0).albedo_texture = wet_texture
	%waterway_2.get_active_material(0).albedo_texture = wet_texture
	%waterway_3.get_active_material(0).albedo_texture = wet_texture
	
func start_waterway():
	%Timer.start(1.5)
	%waterway_col.collision_layer = 2
	%waterway_col.collision_mask = 2

func _on_timer_timeout():
	
	current_step = current_step - 1
	
	if current_step == 2:

#		$"../GroundParticles".position = Vector3($"../MoleSprite".position.x, $"../MoleSprite".position.y, $"../MoleSprite".position.z)
#		$"../GroundParticles".emitting = true
		%waterway_0.hide()
		%waterway_1.show()
		%Timer.start(1)
	
	if current_step == 1:
		%waterway_1.hide()
		%waterway_2.show()
		%Timer.start(1)
		
	if current_step == 0:
		%waterway_2.hide()
		%waterway_3.show()
	
	pass # Replace with function body.
