extends CharacterBody3D

@export var speed := 3.5
@export var gravity := 15.0
@export var current_area := World.Area.NONE

var current_area_ref = null

@onready var state = World.state
@onready var footstepsStreams = [%SeedFootstep_1, %SeedFootstep_2, %SeedFootstep_3]
var moleIsUp = false
var standing_anim = preload("res://assets/semilla_idle/standing.tres")
var walking_anim = preload("res://assets/semilla_walk/walking.tres")

enum AnimState {
	IDLE,
	WALK
}

var character_enabled = false
var anim_state := AnimState.IDLE
var elapsed_time := 0.0
var mole_meters := 0.0

signal player_released_waterfall(depth)

func _ready():
	World.global_player = self
	%Ambience_Night.play()

func _process(delta):
	
	var light : DirectionalLight3D = $"../Nivel/WorldEnvironment/DirectionalLight3D"
	if state.sunIsUp and light.light_energy < 0.7:
		var energy = move_toward(light.light_energy, 0.7, delta*0.2)
		light.light_energy = energy
	process_sprite_audio(delta)
	
	if moleIsUp:
		$"../GroundParticles".position.x-=0.01
		$"../GroundParticles".position.y-=0.002
		
		
func _input(event):
	
	if not character_enabled:
		return
	
	if event.is_action_pressed("Interact"):
		match current_area:
			World.Area.MOLE:
				interact_mole()
			World.Area.WATER:
				interact_water()
			World.Area.SUN:
				interact_sun()
			World.Area.COW:
				interact_cow()
			World.Area.ROOTS:
				interact_roots()
			_:
				print("No area!")
				
		if current_area_ref:
			current_area_ref.deactivate()
	if event.is_action_pressed("Exit"):
		get_tree().quit()

func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if character_enabled:

		var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
		if input_dir:
			velocity.x = input_dir.x * speed
			velocity.z = input_dir.y * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if not character_enabled:
		return

	var mat : StandardMaterial3D = %Sprite/Plane.get_surface_override_material(0)
	if (abs(velocity.z) + abs(velocity.x)) / 2.0 > 0.00:
		mat.albedo_texture = walking_anim
		anim_state = AnimState.WALK
	else:
		mat.albedo_texture = standing_anim
		anim_state = AnimState.IDLE

	if velocity.x > 0.0:
		mat.uv1_scale.x = -1
	elif velocity.x < 0.0:
		mat.uv1_scale.x = 1

func interact_mole():
	$"../MoleAnim".play("mole_up")
	moleIsUp = true
	$"../GroundParticles".position = $"../Mole".position
	$"../GroundParticles".position.x-= 0.05
	$"../GroundParticles".position.y+= 0.1
	$"../GroundParticles".emitting = true

func _on_mole_anim_animation_finished(anim_name):
	
	if anim_name == "mole_up":
		if state.sunIsUp:
			print("MOLE GETS HOT AND MAKES WRONG WATERWAY")

		elif state.groundFlooded:
			print("MOLE GETS AWAY AND DOES NOT MAKE THE WATERWAY")
		elif not state.sunIsUp:
			print("MOLE MAKES CORRECT WATERWAY")
			$"../waterway".start_waterway()
			
			state.actionSequence.push_back("MOLE")
			state.waterwayDone = true
		
		$"../MoleAnim".play("mole_dig")
	elif anim_name == "mole_dig":
		moleIsUp = false
		$"../GroundParticles".emitting = false
		
func interact_water():
	if state.wetGround or state.groundFlooded:
		print("WATER ALREADY FREED")
		return

	if state.waterwayDone and not state.sunIsUp:
		print("WATER GOES THROUGH WATERWAY AND GRASS GROW UP")
		state.actionSequence.push_back("WATER")
		state.wetGround = true
		%RiverStream.play()
		emit_signal("player_released_waterfall", -1.5)
	elif state.waterwayDone and state.sunIsUp:
		print("WATER EVAPORATES")
	elif not state.waterwayDone:
		print("FLOOD THE GROUND")
		state.groundFlooded = true
		%RiverStream.play()
		emit_signal("player_released_waterfall", -1.3)

func interact_sun():
	
	if state.sunIsUp: 
		print("SUN IS ALREADY UP")
		return

	print("SUN IS UP!")
	state.sunIsUp = true
	state.actionSequence.push_back("SUN")
	%Kikiriki.play()

func interact_cow():

	if state.grassEaten:
		print("GRASS ALREADY EATEN")
		return

	if state.waterwayDone and state.wetGround and state.sunIsUp:
		print("COW EATS GRASS")
		state.grassEaten = true
		state.actionSequence.push_back("COW")
	elif not state.waterwayDone and state.groundFlooded:
		print("COW DRINKS WATER")
	elif state.waterwayDone and not state.wetGround:
		print("COW IGNORES EVERYTHING AND GOES AWAY (NO GRASS)")
	elif not state.sunIsUp:
		print("COW WAKES UP, GETS ANGRY AND GOES AWAY")

func interact_roots():
	
	if state.waterwayDone and state.wetGround and state.sunIsUp and state.grassEaten:
		print("WIN CASE!!")
		# Check in case something is really bugged
#		for act in state.actionSequence:
#			print(act)
			
	elif state.waterwayDone and not state.wetGround and not state.sunIsUp:
		print("SHOOT GROWS UP, AFTERWARDS IT DIES")
	elif state.waterwayDone and state.wetGround:
		print("SHOOT AND SOME LEAVES GROWS UP, AFTERWARDS IT DIES")

func process_sprite_audio(delta):
	
	if anim_state == AnimState.WALK:
		elapsed_time += delta
		var frame = walking_anim.current_frame
		if (frame == 1 or frame == 4) and elapsed_time >= walking_anim.get_frame_duration(frame) + 0.01:
			var index = randi() % 3
			footstepsStreams[index].play()
			elapsed_time = 0.0
	else:
		elapsed_time = 0.0
