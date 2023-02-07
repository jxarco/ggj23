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
	
	# Store here stuff so we don't lose it at reset
	var dry_texture = null
	
	func reset():
		waterwayDone = false
		moleOnSurface = false
		moleReturns = false
		wetGround = false
		sunIsUp = false
		grassEaten = false
		groundFlooded = false
		
		actionSequence.clear()

var state = WorldState.new()
var global_player = null
