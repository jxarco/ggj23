extends Node3D

@export var target_pos := 0.0

var water_level_changed = false

func _process(_delta):
	if not water_level_changed:
		return
	
	set_position(Vector3(position.x, move_toward(position.y, target_pos, _delta * 0.5), position.z))

func _on_waterfall_waterfall_has_flooded():
	water_level_changed = true

func _on_player_player_set_day():
	water_level_changed = true
