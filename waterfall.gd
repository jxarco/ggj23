extends Node3D

signal waterfall_is_stablished()

var total_time = 1.0
var time_counter = 0.0
var flowing = false
var stablished = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !flowing:
		return
	time_counter += delta
	%waterfall_body.get_active_material(0).set_shader_parameter("u_current_time", time_counter)

	if time_counter >= total_time and !stablished:
		%particles.emitting = true
		emit_signal("waterfall_is_stablished")
		stablished = true

func _on_player_player_released_waterfall(depth):
	flowing = true




