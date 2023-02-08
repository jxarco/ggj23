extends Control

func _on_good_ending():
	$WinScreen.visible = true
	
func _on_bad_ending():
	$LoseScreen.visible = true
