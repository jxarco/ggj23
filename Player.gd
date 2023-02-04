extends CharacterBody3D

@export var speed := 2.0
var gravity := 15.0

@onready var sprite := %Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	get_node("Mesh/AnimationPlayer").play("Move", -1, 2)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#
	if not is_on_floor():
		velocity.y -= gravity * delta
		
#	if is_on_floor() and jump:
#		velocity.y += jump_speed
#		jump = false
	
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	pass
