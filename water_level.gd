extends Node3D

var target_pos = 0.0
var water_level_changed = false
var stopped := false

# Called when the node enters the scene tree for the first time.
func _ready():
	#target_pos = get_position()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not water_level_changed or stopped:
		return
	
	var position = get_position()

	set_position(Vector3(position.x, move_toward(position.y, target_pos, _delta), position.z))
	
	if position.y >= target_pos:
		$"../MoleAnim".play("grass_scale")
		stopped = true

func _on_player_player_released_waterfall(depth):
	target_pos = depth
	print("target", target_pos)

func _on_waterfall_waterfall_is_stablished():
	water_level_changed = true
	print("water fall stablish received")
	self.set_visible(true)
