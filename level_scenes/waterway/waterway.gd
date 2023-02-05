extends Node3D

var waterway_steps : int = 3
var current_step : int = waterway_steps

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_waterway():
	%Timer.start(1.5)

func _on_timer_timeout():
	
	current_step = current_step - 1
	
	if current_step == 2:
		%waterway_0.hide()
		%waterway_1.show()
		%Timer.start(1)
	
	if current_step == 1:
		%waterway_1.hide()
		%waterway_2.show()
		%Timer.start(1)
		
	if current_step == 0:
		%waterway_2.hide()
		%waterway_3.show()
	
	pass # Replace with function body.
