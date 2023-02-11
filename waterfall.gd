extends Node3D

signal waterfall_is_pond()
signal waterfall_has_flooded()

var total_time = 1.0
var time_counter = 0.0
var flowing = false
var stablished = false
var has_flooded = false

func _ready():
	reset_water()
	%waterfall_body.visible = false

func _process(delta):
	if !flowing:
		return
	time_counter += delta * 0.75
	%waterfall_body.get_active_material(0).set_shader_parameter("u_current_time", time_counter)

	if time_counter >= total_time and !stablished:
		%particles.emitting = true
		%particles3_new.emitting = true
		
		if has_flooded:
			emit_signal("waterfall_has_flooded")
		else:
			emit_signal("waterfall_is_pond")
		stablished = true

func reset_water():
	%waterfall_body.get_active_material(0).set_shader_parameter("u_current_time", 0)

func _on_player_player_released_waterfall(flood):
	%waterfall_body.visible = true
	flowing = true
	has_flooded = flood

func _on_player_player_set_day():
	flowing = false
	%particles.emitting = false
	%particles3_new.emitting = false
	
	reset_water()
