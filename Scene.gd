extends Node3D

@onready var state = World.state

# STATES:
#	waterwayDone : bool = false
#	wetGround : bool
#	sunIsUp : bool
#	grassEaten : bool

# ACTIONS: MOLE_CALL, FREE_WATER, COW_CALL, WAIT4SUN,ROOT
	
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
	if state.waterwayDone and not state.grassEaten and not state.sunIsUp:
		print("WATER GOES THROUGH WATERWAY AND GRASS GROW UP")
		state.wetGround = true
	elif state.waterwayDone and state.sunIsUp:
		print("WATER EVAPORATES")
	elif not state.waterwayDone:
		print("FLOOD THE GROUND")
	
