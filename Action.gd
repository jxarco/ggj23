extends Node3D

signal player_entered(player)
signal player_exited(player)

func _ready():
	pass

func _process(_delta):
	pass

func _on_area_3d_body_entered(body):
	emit_signal("player_entered", body)

func _on_area_3d_body_exited(body):
	emit_signal("player_exited", body)
	# Reset area on exit
	body.current_area = World.Area.NONE
	print("No area")
