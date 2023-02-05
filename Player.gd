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

var isBackwardsAnim : bool = false

enum AnimState {
	IDLE,
	WALK
}

var character_enabled = false
var anim_state := AnimState.IDLE
var elapsed_time := 0.0
var mole_meters := 0.0
var enable_movement : bool = true
var playing_mole_backwards : bool = false
var growing := false
var grow_current_time := 0.0
var grow_sequence : Array

signal player_released_waterfall(flood)
signal player_set_day()
signal win()
signal lose()

func _ready():
	World.global_player = self
	%Ambience_Night.play()

func _process(delta):
	
	var light : DirectionalLight3D = $"../Nivel/WorldEnvironment/DirectionalLight3D"
	if state.sunIsUp:
		var energy = move_toward(light.light_energy, 0.9, delta*0.2)
		light.light_energy = energy
		# Interpolate also color tint (Color())
		light.light_color.r = move_toward(light.light_color.r, 0.96, delta*0.2)
		light.light_color.g = move_toward(light.light_color.g, 0.88, delta*0.2)
		light.light_color.b = move_toward(light.light_color.b, 0.76, delta*0.2)
		
	process_sprite_audio(delta)
	
	if moleIsUp and not state.sunIsUp and not state.groundFlooded:
		$"../GroundParticles".position.x-=0.015
		$"../GroundParticles".position.y-=0.002
	
	if growing:
		process_final_plant(delta)
		
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
	
	if not enable_movement:
		return

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
		
func play_anim(name):
	$AnimationPlayer.play(name)
	enable_movement = false
	$SpringArm3D.collision_mask = 0
	
	var mat : StandardMaterial3D = %Sprite/Plane.get_surface_override_material(0)
	mat.albedo_texture = standing_anim
	anim_state = AnimState.IDLE

func interact_mole():
	$"../MoleAnim".play("mole_up")
	moleIsUp = true
	$"../GroundParticles".position = $"../Mole".position
	$"../GroundParticles".position.x-= 0.05
	$"../GroundParticles".position.y+= 0.1
	$"../GroundParticles".emitting = true
	play_anim("focus_topo")

func _on_mole_anim_animation_finished(anim_name):
	
	if playing_mole_backwards:
		playing_mole_backwards = false
		$"../GroundParticles".emitting = false
		return
	
	if anim_name == "mole_up":
		if state.sunIsUp:
			print("MOLE GETS HOT AND MAKES WRONG WATERWAY")
			$"../MoleAnim".play_backwards("mole_up")
			playing_mole_backwards = true
			$AudioStreams/MoleDiggingWrong.play()
		elif state.groundFlooded:
			print("MOLE GETS AWAY AND DOES NOT MAKE THE WATERWAY")
			$"../MoleAnim".play_backwards("mole_up")
			playing_mole_backwards = true
			$AudioStreams/MoleDiggingWrong.play()
		elif not state.sunIsUp:
			print("MOLE MAKES CORRECT WATERWAY")
			$"../MoleAnim".play("mole_dig")
			$"../waterway".start_waterway()
			$AudioStreams/MoleDigging.play()
			state.actionSequence.push_back("MOLE")
			state.waterwayDone = true

	elif anim_name == "mole_dig":
		moleIsUp = false
		$"../GroundParticles".emitting = false
		
func interact_water():

	if state.sunIsUp:
		print("WATER EVAPORATED")
		return

	if state.waterwayDone:
		print("WATER GOES THROUGH WATERWAY AND GRASS GROW UP")
		play_anim("focus_water_elevate")
		state.actionSequence.push_back("WATER")
		state.wetGround = true
		%RiverStream.play()
		$"../waterway".set_wet()
		emit_signal("player_released_waterfall", false)
	else:
		print("FLOOD THE GROUND")
		play_anim("focus_water_elevate")
		state.groundFlooded = true
		%RiverStream.play()
		$"../waterway".set_wet()
		emit_signal("player_released_waterfall", true)

func interact_sun():

	emit_signal("player_set_day")
	
	print("SUN IS UP!")
	state.sunIsUp = true
	state.actionSequence.push_back("SUN")
	%Kikiriki.play()
	
	if state.wetGround or state.groundFlooded:
		play_anim("focus_water")
	
	%Ambience_Night.stop()
	%Ambience_Day.play()

func interact_cow():

	if state.waterwayDone and state.wetGround and state.sunIsUp:
		print("COW EATS GRASS")
		state.grassEaten = true
		state.actionSequence.push_back("COW")
		$"../CowAnim".play("cow_head")
		play_anim("focus_cow")
		$AudioStreams/CowEating.play()
	elif not state.waterwayDone and state.groundFlooded:
		print("COW DRINKS WATER")
	elif state.waterwayDone and not state.wetGround:
		print("COW IGNORES EVERYTHING AND GOES AWAY (NO GRASS)")
	elif not state.sunIsUp:
		print("COW WAKES UP, GETS ANGRY AND GOES AWAY")
		$AudioStreams/CowAngry.play()
	
func _on_cow_anim_animation_finished(anim_name):
	print("GRASS DISAPEARS")
	$"../Grass".visible = false

func interact_roots():
	
	enable_movement = false
	character_enabled = false
	
	var game_case = 0
	
	# Caso 0 - Horrible
	if not state.wetGround and not state.sunIsUp:
		print("0 - SHOOT DOES NOT GROW")
		emit_signal("lose")
		return
	# Caso 1 - Malo
	elif state.wetGround and !state.sunIsUp and not state.grassEaten:
		print("1 - SOME LEAVES GROWS UP, AFTERWARDS IT DIES")
		game_case = 1
	# Caso 2 - Menos malo
	elif state.wetGround and state.sunIsUp and not state.grassEaten:
		print("2 - SHOOT AND SOME LEAVES GROWS UP, AFTERWARDS IT DIES")
		game_case = 2
	# Caso 3 - Bueno
	elif state.wetGround and state.sunIsUp and state.grassEaten:
		print("WIN CASE!!")
		game_case = 3
		
	$FinalPlant.visible = true
	growing = true
		
	var base_layer : MeshInstance3D = $FinalPlant/base_layer
	var top_layer : MeshInstance3D = $FinalPlant/top_layer
	var tayo : MeshInstance3D = $FinalPlant/tayo
	var tayo_final : MeshInstance3D = $FinalPlant/tayo_final
	
	var mat_bl : ShaderMaterial = base_layer.get_surface_override_material(0)
	var mat_tl : ShaderMaterial = top_layer.get_surface_override_material(0)
	var mat_t : ShaderMaterial = tayo.get_surface_override_material(0)
	var mat_tf : ShaderMaterial = tayo_final.get_surface_override_material(0)
	
	mat_tl.set_shader_parameter("u_current_time", 0)
	mat_t.set_shader_parameter("u_current_time", 0)
	mat_tf.set_shader_parameter("u_current_time", 0)
	mat_bl.set_shader_parameter("u_current_time", 0)
		
	match game_case:
		1:
			grow_sequence.push_back(0)
			grow_sequence.push_back(-1)
		2:
			grow_sequence.push_back(0)
			grow_sequence.push_back(1)
			grow_sequence.push_back(2)
			grow_sequence.push_back(-1)
		3:
			grow_sequence.push_back(0)
			grow_sequence.push_back(1)
			grow_sequence.push_back(2)
			grow_sequence.push_back(3)
			grow_sequence.push_back(-1)
	
		
	character_enabled = false

func process_final_plant(delta):
	
		grow_current_time += delta * 1.5
		
		var base_layer : MeshInstance3D = $FinalPlant/base_layer
		var top_layer : MeshInstance3D = $FinalPlant/top_layer
		var tayo : MeshInstance3D = $FinalPlant/tayo
		var tayo_final : MeshInstance3D = $FinalPlant/tayo_final
		
		var mat_bl : ShaderMaterial = base_layer.get_surface_override_material(0)
		var mat_tl : ShaderMaterial = top_layer.get_surface_override_material(0)
		var mat_t : ShaderMaterial = tayo.get_surface_override_material(0)
		var mat_tf : ShaderMaterial = tayo_final.get_surface_override_material(0)
		
		if grow_sequence.size() == 0:
			return
			
		var next = grow_sequence[0]
		match next:
			0:
				mat_bl.set_shader_parameter("u_current_time", clamp(grow_current_time, 0.0, 2.0))
				if grow_current_time >= 2:
					grow_current_time = 0
					grow_sequence.pop_front()
			1:
				mat_t.set_shader_parameter("u_current_time", clamp(grow_current_time, 0.0, 2.0))
				if grow_current_time >= 2:
					grow_current_time = 0
					grow_sequence.pop_front()
			2:
				mat_tl.set_shader_parameter("u_current_time", clamp(grow_current_time, 0.0, 2.0))
				if grow_current_time >= 2:
					grow_current_time = 0
					grow_sequence.pop_front()
			3:
				mat_tf.set_shader_parameter("u_current_time", clamp(grow_current_time, 0.0, 2.0))
				if grow_current_time >= 2:
					grow_current_time = 0
					grow_sequence.pop_front()
			-1:
				emit_signal("win")
				pass
		

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


func _on_animation_player_animation_finished(anim_name):
	
	if isBackwardsAnim:
		isBackwardsAnim = false
		enable_movement = true
		$SpringArm3D.collision_mask = 2
		return
	
	if anim_name == "focus_cow":
		$AnimationPlayer.play_backwards("focus_cow")
	if anim_name == "focus_water":
		$AnimationPlayer.play_backwards("focus_water")
	if anim_name == "focus_topo":
		$AnimationPlayer.play_backwards("focus_topo")
	if anim_name == "focus_water_elevate":
		$AnimationPlayer.play_backwards("focus_water_elevate")
		
	isBackwardsAnim = true


func _on_win():
	$"../Control/WinScreen".show()


func _on_lose():
	$"../Control/LoseScreen".show()
