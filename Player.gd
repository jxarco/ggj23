extends CharacterBody3D

@export var speed := 2.0
var gravity := 15.0

@onready var sprite := %AnimatedSprite3D

var walking_anim = preload("res://assets/walking.tres")
var standing_anim = preload("res://assets/standing.tres")

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

	var mat : StandardMaterial3D = %Sprite/Plane.get_surface_override_material(0)
	if (abs(velocity.z) + abs(velocity.x)) / 2.0 > 0.00:
		mat.albedo_texture = walking_anim

#		sprite.play("walking")
	else:
		mat.albedo_texture = standing_anim
#		sprite.play("standing")

	if velocity.x > 0.0:
		mat.uv1_scale.x = -1
	elif velocity.x < 0.0:
		mat.uv1_scale.x = 1
#
#	for i in range(get_slide_collision_count() - 1):
#		var collision = get_slide_collision(i)
#		print(collision)

	pass
