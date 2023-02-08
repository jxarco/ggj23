extends CharacterBody3D

@export var speed := 3.5
@export var gravity := 15.0
@export var current_area := World.Area.NONE

var current_area_ref = null

@onready var state = World.state
@onready var footstepsStreams = [%SeedFootstep_1, %SeedFootstep_2, %SeedFootstep_3]
var moleIsUp = false

var standing_anim = preload("res://assets/semilla_idle/standing.tres")
var standing_anim_emissive = preload("res://assets/semilla_idle/standing_emissive.tres")
var walking_anim = preload("res://assets/semilla_walk/walking.tres")
var walking_anim_emissive = preload("res://assets/semilla_walk/walking_emissive.tres")

var isBackwardsAnim : bool = false

enum AnimState {
	IDLE,
	WALK
}

enum RootPlantState {
	FINISHED = -1,
	BASE,
	STEM,
	TOP,
	FLOWER
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
var cam_out = false
var light : DirectionalLight3D

signal player_released_waterfall(flood)
signal player_set_day()
signal win()
signal lose()
signal reset_requested()

func _ready():
	World.global_player = self
	%Ambience_Night.play()
	
	light = $"../Nivel/WorldEnvironment/DirectionalLight3D"
	light.light_color = Color(0.55294120311737, 0.69411766529083, 1)
	light.light_energy = 0.25
	
func _process(delta):
	
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
		
	if cam_out:
		$SpringArm3D.position.y = move_toward($SpringArm3D.position.y, 3, delta * 0.5)
		$SpringArm3D.position.z = move_toward($SpringArm3D.position.z, 0.3, delta * 0.5)
		
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
		mat.emission_texture = walking_anim_emissive
		anim_state = AnimState.WALK
	else:
		mat.albedo_texture = standing_anim
		mat.emission_texture = standing_anim_emissive
		anim_state = AnimState.IDLE

	if velocity.x > 0.0:
		mat.uv1_scale.x = -1
	elif velocity.x < 0.0:
		mat.uv1_scale.x = 1
		
func set_idle_anim():
	var mat : StandardMaterial3D = %Sprite/Plane.get_surface_override_material(0)
	mat.albedo_texture = standing_anim
	mat.emission_texture = standing_anim_emissive
	anim_state = AnimState.IDLE
		
func play_anim(anim_name):
	$AnimationPlayer.play(anim_name)
	enable_movement = false
	$SpringArm3D.collision_mask = 0
	set_idle_anim()

func interact_mole():
	$"../MoleAnim".play("mole_up")
	moleIsUp = true
	$"../GroundParticles".position = $"../Mole".position
	$"../GroundParticles".position.x -= 0.3
	$"../GroundParticles".position.z -= 0.4
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

	$"../Waterfall".show()
	$"../waterway".set_wet()
	$"../RiverStream".play()
	play_anim("focus_water_elevate")

	if state.waterwayDone:
		print("WATER GOES THROUGH WATERWAY AND GRASS GROW UP")
		state.actionSequence.push_back("WATER")
		state.wetGround = true
		emit_signal("player_released_waterfall", false)
	else:
		print("FLOOD THE GROUND")
		state.groundFlooded = true
		emit_signal("player_released_waterfall", true)

func interact_sun():

	emit_signal("player_set_day")
	
	print("SUN IS UP!")
	state.sunIsUp = true
	state.actionSequence.push_back("SUN")
	%Kikiriki.play()
	
	play_anim("focus_water")
			
	if state.wetGround or state.groundFlooded:
		$"../RiverStream".stop()
	
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
	else:
		print("COW WAKES UP, GETS ANGRY AND GOES AWAY")
		$AudioStreams/CowAngry.play()
	
func _on_cow_anim_animation_finished(_anim_name):
	$"../Grass".visible = false

func interact_roots():
	
	set_idle_anim()
	
	enable_movement = false
	character_enabled = false
	cam_out = true
	
	var game_case = 0
	
	# Caso 1 - Malo
	if state.wetGround and not state.sunIsUp and not state.grassEaten:
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
	# Caso 0 - Horrible
	else:
		print("0 - SHOOT DOES NOT GROW")
		var timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(func ():
			emit_signal("lose")
		)
		timer.start(3)
		return
		
	$FinalPlant.visible = true
	%Sprite.visible = false
	growing = true
		
	var base_layer : MeshInstance3D = $FinalPlant/base_layer
	var top_layer : MeshInstance3D = $FinalPlant/top_layer
	var tayo : MeshInstance3D = $FinalPlant/tayo
	var tayo_final : MeshInstance3D = $FinalPlant/tayo_final
	
	var mat_bl : ShaderMaterial = base_layer.get_surface_override_material(0)
	var mat_tl : ShaderMaterial = top_layer.get_surface_override_material(0)
	var mat_t : ShaderMaterial = tayo.get_surface_override_material(0)
	var mat_tf : ShaderMaterial = tayo_final.get_surface_override_material(0)
	
	grow_current_time = 0.0
	
	mat_tl.set_shader_parameter("u_current_time", 0.0)
	mat_t.set_shader_parameter("u_current_time", 0.0)
	mat_tf.set_shader_parameter("u_current_time", 0.0)
	mat_bl.set_shader_parameter("u_current_time", 0.0)
		
	match game_case:
		1:
			grow_sequence.push_back(RootPlantState.BASE)
			grow_sequence.push_back(RootPlantState.FINISHED)
		2:
			grow_sequence.push_back(RootPlantState.BASE)
			grow_sequence.push_back(RootPlantState.STEM)
			grow_sequence.push_back(RootPlantState.TOP)
			grow_sequence.push_back(RootPlantState.FINISHED)
		3:
			grow_sequence.push_back(RootPlantState.BASE)
			grow_sequence.push_back(RootPlantState.STEM)
			grow_sequence.push_back(RootPlantState.TOP)
			grow_sequence.push_back(RootPlantState.FLOWER)
			grow_sequence.push_back(RootPlantState.FINISHED)
	
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
		
		var update_shader : Callable = func (mat : ShaderMaterial):
			mat.set_shader_parameter("u_current_time", clamp(grow_current_time, 0.0, 2.0))
			if grow_current_time >= 2:
				grow_current_time = 0
				grow_sequence.pop_front()
		
		var next = grow_sequence[0]
		match next:
			RootPlantState.BASE:
				update_shader.call(mat_bl)
			RootPlantState.STEM:
				update_shader.call(mat_t)
			RootPlantState.TOP:
				update_shader.call(mat_tl)
			RootPlantState.FLOWER:
				update_shader.call(mat_tf)
			RootPlantState.FINISHED:
				var timer = Timer.new()
				add_child(timer)
				timer.timeout.connect(func ():
					emit_signal("win")
				)
				timer.start(3)

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
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(func ():
		emit_signal("reset_requested")
	)
	timer.start(3)

func _on_lose():
	$"../Control/LoseScreen".show()
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(func ():
		emit_signal("reset_requested")
	)
	timer.start(3)
