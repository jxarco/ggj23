extends Node

# World attributes/conditions

class WorldState:
	
	enum Actions {
		MOLE_CALL,
		FREE_WATER,
		COW_CALL,
		WAIT4SUN,
		ROOT
	}
	
	var sequence : Array
	
	var waterwayDone : bool = false
	var wetGround : bool
	var sunIsUp : bool
	var grassEaten : bool

var state = WorldState.new()
