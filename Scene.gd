extends Node3D

signal reset()

func _ready():
	$Menu/MusicStream.play()
	$Grass.rotation_degrees = Vector3(0, -180, 0)
	$Grass.set_scale(Vector3(0.01, 0.01, 0.01))

func _process(_delta):
	%FPS.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_mole_player_entered(player):
	player.current_area = World.Area.MOLE

func _on_water_player_entered(player):
	player.current_area = World.Area.WATER

func _on_sun_player_entered(player):
	player.current_area = World.Area.SUN

func _on_cow_player_entered(player):
	player.current_area = World.Area.COW

func _on_roots_player_entered(player):
	player.current_area = World.Area.ROOTS


func _on_player_reset_requested():
	emit_signal("reset")
	pass # Replace with function body.
