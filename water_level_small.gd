extends Node3D

@export
var target_pos := 0.0

var water_level_changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !water_level_changed:
		return
	
	var position = get_position()

	set_position(Vector3(position.x, move_toward(position.y, target_pos, _delta * 0.5), position.z))


func _on_waterfall_waterfall_is_pond():
	water_level_changed = true
