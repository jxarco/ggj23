extends CharacterBody3D

@export var speed := 2.0
@export var gravity := 15.0
@export var current_area := World.Area.NONE

@onready var state = World.state
@onready var sprite := %AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	get_node("Mesh/AnimationPlayer").play("Move", -1, 2)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.get_action_strength("Interact"):
		interact()

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
	
	if (abs(velocity.z) + abs(velocity.x)) / 2.0 > 0.00:
		sprite.play("walking")
	else:
		sprite.play("standing")
	
	if velocity.x > 0.0:
		sprite.flip_h = false
	elif velocity.x < 0.0:
		sprite.flip_h = true
#
#	for i in range(get_slide_collision_count() - 1):
#		var collision = get_slide_collision(i)
#		print(collision)
	

func interact():
	
	match current_area:
		World.Area.MOLE:
			print("i'm in MOLE area")
			if state.waterwayDone:
				print("WATERWAY ALREADY DONE")
				return
				
			if state.sunIsUp:
				print("MOLE GETS HOT AND MAKES WRONG WATERWAY")
			elif not state.sunIsUp:
				print("MOLE MAKES CORRECT WATERWAY")
				state.waterwayDone = true
		World.Area.WATER:
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
		World.Area.COW:
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
		_:
			print("No area!")
