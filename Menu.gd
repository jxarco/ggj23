extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("Interact"):
		World.global_player.character_enabled = true
		$Panel.visible = false
		$MusicStream.volume_db = -15

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _input(event):
	
		

#func _on_pressed():
#	World.global_player.character_enabled = true
#	$"../..".visible = false
#	$"../../MusicStream".volume_db = -15
