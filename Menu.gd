extends Control

var started := false
var target_bck_volume := -18

func _ready():
	started = false

func _process(delta):
	
	if started and $MusicStream.volume_db != target_bck_volume:
		$MusicStream.volume_db = move_toward($MusicStream.volume_db, target_bck_volume, delta * 5.0)
	
	if Input.is_action_pressed("Interact"):
		World.global_player.character_enabled = true
		$MenuAnimation.play("fade_out")
		started = true


func _on_menu_animation_animation_finished(_anim_name):
	$Panel.visible = false
