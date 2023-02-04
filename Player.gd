extends CharacterBody3D

@export var speed := 2.0
@export var gravity := 15.0
@export var current_area := World.Area.NONE

@onready var state = World.state
@onready var sprite := %AnimatedSprite3D

var walking_anim = preload("res://assets/walking.tres")
var standing_anim = preload("res://assets/standing.tres")

# Called when the node enters the scene tree for the first time.
func _ready():

#	get_node("Mesh/AnimationPlayer").play("Move", -1, 2)
	pass

func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("Interact"):
		match current_area:
			World.Area.MOLE:
				interact_mole()
			World.Area.WATER:
				interact_water()
			World.Area.COW:
				interact_cow()
			_:
				print("No area!")

func _physics_process(delta):
#
	if not is_on_floor():
		velocity.y -= gravity * delta

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

func interact_mole():

	print("i'm in MOLE area")
	if state.waterwayDone:
		print("WATERWAY ALREADY DONE")
		return

	if state.sunIsUp:
		print("MOLE GETS HOT AND MAKES WRONG WATERWAY")
	elif not state.sunIsUp:
		print("MOLE MAKES CORRECT WATERWAY")
		state.waterwayDone = true

func interact_water():

	print("i'm in WATER area")
	if state.wetGround:
		print("WATER ALREADY TO THE WATERWAY")
		return

	if state.waterwayDone and not state.grassEaten and not state.sunIsUp:
		print("WATER GOES THROUGH WATERWAY AND GRASS GROW UP")
		state.wetGround = true
	elif state.waterwayDone and state.sunIsUp:
		print("WATER EVAPORATES")
	elif not state.waterwayDone:
		print("FLOOD THE GROUND")

func interact_cow():

	print("i'm in COW area")
	if state.grassEaten:
		print("GRASS ALREADY EATEN")
		return

	if state.waterwayDone and state.wetGround and state.sunIsUp:
		print("COW EATS GRASS")
		state.grassEaten = true
	elif state.waterwayDone and state.wetGround and not state.sunIsUp:
		print("COW WAKES UP, GETS ANGRY AND GOES AWAY")
	elif not state.waterwayDone and state.wetGround:
		print("COW DRINKS WATER")
	elif state.waterwayDone and not state.wetGround:
		print("COW IGNORES EVERYTHING AND GOES AWAY (NO GRASS)")

func interact_root():
	print("i'm in ROOT area")
	
	if state.waterwayDone and state.wetGround and state.sunIsUp and state.grassEaten:
		print("WIN")
	elif state.waterwayDone and not state.wetGround and not state.sunIsUp:
		print("SHOOT GROWS UP, AFTERWARDS IT DIES")
	elif state.waterwayDone and state.wetGround:
		print("SHOOT AND SOME LEAVES GROWS UP, AFTERWARDS IT DIES")
