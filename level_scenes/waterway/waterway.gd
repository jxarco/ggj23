extends Node3D

var waterway_steps : int = 2
var current_step : int = waterway_steps

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_waterway():
	%Timer.start()

func _on_timer_timeout():
	
	current_step = current_step - 1
	
	if current_step == 1:
		%waterway_0.hide()
		%waterway_1.show()
		
	if current_step == 0:
		%waterway_1.hide()
		%waterway_2.show()
		%Timer.stop()
	
	pass # Replace with function body.
