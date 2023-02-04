extends Node3D

@onready var state = World.state

#	var waterwayDone : bool = false
#	var wetGround : bool
#	var sunIsUp : bool
#	var grassEaten : bool

func _on_cow_player_entered(player):
	print("cow")
	if state.waterwayDone and state.wetGround and state.sunIsUp:
		print("COW EATS GRASS")
		state.grassEaten = true
	elif state.waterwayDone and state.wetGround and not state.sunIsUp:
		print("COW WAKES UP, GETS ANGRY AND GOES AWAY")
	elif not state.waterwayDone and state.wetGround:
		print("COW DRINKS WATER")
	elif state.waterwayDone and not state.wetGround:
		print("COW IGNORES EVERYTHING AND GOES AWAY (NO GRASS)")

func _on_water_player_entered(player):
	print("water")
	pass # Replace with function body.

func _on_mole_player_entered(player):
	print("mole")
	if state.waterwayDone:
		print("WATERWAY ALREADY DONE")
		return
		
	if state.sunIsUp:
		print("MOLE GETS HOT AND MAKES WRONG WATERWAY")
	elif not state.sunIsUp:
		print("MOLE MAKES CORRECT WATERWAY")
		state.waterwayDone = true
