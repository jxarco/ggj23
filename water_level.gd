extends Node3D

var target_pos = 0.0
var water_level_changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	target_pos = get_position()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !water_level_changed:
		return
	
	var position = get_position()

	set_position(Vector3(position.x, move_toward(position.y, target_pos, _delta), position.z))


func _on_player_player_released_waterfall(depth):
	target_pos = depth
	print("target", target_pos)



func _on_waterfall_waterfall_is_stablished():
	water_level_changed = true
	print("water fall stablish recived")
	self.set_visible(true)
