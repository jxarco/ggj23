extends Node3D

func _on_cow_player_entered(player):
	player.current_area = World.Area.COW

func _on_water_player_entered(player):
	player.current_area = World.Area.WATER
	
func _on_mole_player_entered(player):
	player.current_area = World.Area.MOLE
	
