extends Node3D

@export var target_pos := 0.0

var water_level_changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not water_level_changed:
		return
	
	var pos = get_position()
	set_position(Vector3(pos.x, move_toward(pos.y, target_pos, _delta * 0.5), pos.z))


func _on_waterfall_waterfall_has_flooded():
	water_level_changed = true
