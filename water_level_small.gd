extends Node3D

@export var target_pos := 0.0
var stopped := false
var water_level_changed = false

func _process(_delta):
	if !water_level_changed or stopped:
		return
	
	set_position(Vector3(position.x, move_toward(position.y, target_pos, _delta * 0.5), position.z))

	if position.y >= target_pos:
		$"../MoleAnim".play("grass_scale")
		stopped = true

func _on_waterfall_waterfall_is_pond():
	water_level_changed = true
