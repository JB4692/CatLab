extends Control

@onready var splash = $Splash
@onready var anim = $AnimationPlayer
@onready var menu = $Menu
@onready var circles = $circles
@onready var logo = $Logo
@onready var a1 = $a1
@onready var a2 = $a2
@onready var a3 = $a3

func _ready():
	circles.modulate = Color(1, 1, 1, 0.3) 
	circles.visible = false
	menu.visible = false
	logo.visible = false
	
	anim.play("intro")
	await anim.animation_finished
	
	var tween = create_tween()
	tween.tween_property(splash, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(menu, "modulate:a", 1.0, 0.5)
	a1.visible = false
	a2.visible = false
	a3.visible = false
	circles.visible = true
	menu.visible = true
	logo.visible = true


func _on_start_button_button_down():
	get_tree().change_scene_to_file("res://scenes/levelcreator.tscn")


func _on_quit_button_button_down():
	get_tree().quit()
