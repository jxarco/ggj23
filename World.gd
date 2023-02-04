extends Node

# World attributes/conditions

enum Area {
		NONE,
		MOLE,
		WATER,
		SUN,
		COW,
		ROOTS
	}

class WorldState:
	
	enum Actions {
		MOLE_CALL,
		FREE_WATER,
		WAIT4SUN,
		COW_CALL,
		ROOT
	}
	
	var actionSequence : Array
	
	var waterwayDone := false
	var moleOnSurface := false
	var moleReturns := false
	var wetGround := false
	var sunIsUp := false
	var grassEaten := false
	var groundFlooded := false

var state = WorldState.new()
