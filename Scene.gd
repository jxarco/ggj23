extends Node3D

func _process(delta):
	%FPS.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_mole_player_entered(player):
	print("MOLE area")
	player.current_area = World.Area.MOLE

func _on_water_player_entered(player):
	print("WATER area")
	player.current_area = World.Area.WATER

func _on_sun_player_entered(player):
	print("SUN area")
	player.current_area = World.Area.SUN

func _on_cow_player_entered(player):
	print("COW area")
	player.current_area = World.Area.COW

func _on_roots_player_entered(player):
	print("ROOTS area")
	player.current_area = World.Area.ROOTS
