extends Node3D

var time = 0.0

func _on_player_player_released_waterfall(_depth):
	$GPUParticles3D.emitting = true
	$piedra.hide()
