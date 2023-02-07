extends Node3D

signal player_entered(player)
signal player_exited(player)

func _ready():
	pass

func _process(_delta):
	pass
	
func deactivate():
	%EnvironmentParticles/GPUParticles3D.emitting = false
	%Area3D.collision_layer = 0
	%Area3D.collision_mask = 0

func _on_area_3d_body_entered(body):
	body.current_area_ref = $"."
	emit_signal("player_entered", body)

func _on_area_3d_body_exited(body):
	body.current_area_ref = null
	emit_signal("player_exited", body)
	# Reset area on exit
	body.current_area = World.Area.NONE
