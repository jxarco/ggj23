extends Node3D

signal waterfall_is_pond()
signal waterfall_has_flooded()

var total_time = 1.0
var time_counter = 0.0
var flowing = false
var stablished = false
var has_flooded = false
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

		if has_flooded:
			emit_signal("waterfall_has_flooded")
		else:
			emit_signal("waterfall_is_pond")
		stablished = true

	#flowing = true


func _on_player_player_released_waterfall(flood):
	flowing = true
	has_flooded = flood


func _on_player_player_set_day():
	flowing = false
	%particles.emitting = false
	%waterfall_body.get_active_material(0).set_shader_parameter("u_current_time", 0)

