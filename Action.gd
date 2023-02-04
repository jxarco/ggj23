extends Node3D

signal player_entered(player)
signal player_exited(player)

# State of the actor
var inside : bool = false

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	inside = true
	emit_signal("player_entered", body)

func _on_area_3d_body_exited(body):
	inside = false
	emit_signal("player_exited", body)
