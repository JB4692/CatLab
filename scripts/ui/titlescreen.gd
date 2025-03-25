extends Control


func _on_start_button_button_down():
	get_tree().change_scene_to_file("res://scenes/levelcreator.tscn")


func _on_credit_button_button_down():
	pass # Replace with credits screen if we want (just a placeholder button)


func _on_quit_button_button_down():
	get_tree().quit()
