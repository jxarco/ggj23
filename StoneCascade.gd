extends Node3D

var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#%piedra1.position.y += cos(clamp(time, 0, 2 * PI))
	#print(cos(clamp(time, 0, 2.0 * PI)))
	#time += delta
	pass


func _on_player_player_released_waterfall(depth):
	
	$GPUParticles3D.emitting = true
	$piedra.hide()
