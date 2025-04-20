extends Control

var process_id = null

func _ready():
	$circles.modulate = Color(1, 1, 1, 0.3) 

func _on_edit_button_button_down():
	get_tree().change_scene_to_file("res://scenes/levelcreator.tscn")

func _on_replay_button_button_down():
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_return_button_button_down():
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
