extends Control

var process_id = null

func _on_start_button_button_down():
	get_tree().change_scene_to_file("res://scenes/levelcreator.tscn")


func _on_quit_button_button_down():
	get_tree().quit()
