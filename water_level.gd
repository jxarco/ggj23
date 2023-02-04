extends Node3D

var target_pos = Vector3()
var water_level_changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	target_pos = get_position()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !water_level_changed:
		return
	
	var position_diff = target_pos - get_position() 
	set_position(get_position() + lerp(Vector3(0.0, 0.0, 0.0), position_diff, 0.25 * _delta));


func _on_player_player_released_waterfall(depth):
	var old_pos = get_position()
	target_pos = Vector3(old_pos.x, depth, old_pos.z)



func _on_waterfall_waterfall_is_stablished():
	water_level_changed = true
	print("water fall stablish recived")
	self.set_visible(true)
