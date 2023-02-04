extends Node

# World attributes/conditions

enum Area {
		NONE,
		MOLE,
		WATER,
		COW,
		ROOTS
	}

class WorldState:
	
	enum Actions {
		MOLE_CALL,
		FREE_WATER,
		COW_CALL,
		WAIT4SUN,
		ROOT
	}
	
	var actionSequence : Array
	
	var waterwayDone : bool = false
	var wetGround : bool
	var sunIsUp : bool
	var grassEaten : bool

var state = WorldState.new()
