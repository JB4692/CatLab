extends CanvasLayer

var is_hovering = false
var in_menu = false
var currentMode = 0 # 0 - title, 1 - create, 2 - play

func _ready():
	$UI/TabButton.visible = false
	$UI/MenuContainer.visible = false
	$UI/OpenTabButton.visible = false
	$UI/Notification.visible = false
	$UI/Confirmation.visible = false

	
func _on_hover_mouse_entered():
	if not is_hovering:
		print("hi")
		is_hovering = true
		#$UI/MenuAnimator.play("fadegradient")
		$UI/TabButton.visible = true
		$UI/MenuAnimator.play("tabin")
		$HideDelayTimer.stop()
	
func _on_hover_mouse_exited():
	is_hovering = false
	$HideDelayTimer.start()

	
func _on_HideDelayTimer_timeout():
	$UI/MenuAnimator.play("tabout")
	
func _on_animation_finished(anim_name):
	if anim_name == "tabout" && !in_menu:
		print("huh")
		is_hovering = false
		$UI/TabButton.visible = false
		#$UI/MenuAnimator.play("fadegradientin")
		$UI/HoverArea.visible = true
	
func _on_TabButton_pressed():
	in_menu = true
	#$UI/MenuAnimator.play("fadegradient")
	$UI/HoverArea.visible = false
	$UI/TabButton.visible = false
	$UI/OpenTabButton.visible = true
	$UI/MenuContainer.visible = true

	$UI/MenuAnimator.play("slide_up")
	
func _on_OpenTabButton_pressed():
	in_menu = false
	$UI/HoverArea.visible = true
	$UI/TabButton.visible = false
	$UI/OpenTabButton.visible = false
	
	$UI/MenuAnimator.play("slidein")

	$UI/MenuContainer.visible = false
	
func _on_HomeButton_pressed():
	currentMode = 0
	_handleConfirmation_switch();
	
func _on_CreateButton_pressed():
	currentMode = 1
	_handleConfirmation_switch();

func _on_PlayButton_pressed():
	currentMode = 2
	_handleConfirmation_switch();
	
func _handleConfirmation_switch():
	$UI/Confirmation.visible = true
	if currentMode == 0:
		$UI/Confirmation/TitleText.visible = true
		$UI/Confirmation/CreateText.visible = false
		$UI/Confirmation/PlayText.visible = false

	elif currentMode == 1:
		$UI/Confirmation/TitleText.visible = false
		$UI/Confirmation/CreateText.visible = true
		$UI/Confirmation/PlayText.visible = false
		
	elif currentMode == 2:
		$UI/Confirmation/TitleText.visible = false
		$UI/Confirmation/CreateText.visible = false
		$UI/Confirmation/PlayText.visible = true

func _on_yes_button_button_down():
	if currentMode == 0:
		get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
	elif currentMode == 1:
		get_tree().change_scene_to_file("res://scenes/levelcreator.tscn")
	elif currentMode == 2:
		$UI/Confirmation.visible = false
		$UI/Notification.visible = true
		$"UI/PawPrint Anim".visible = true
		$UI/TabButton.visible = false
		$UI/MenuContainer.visible = false
		$UI/OpenTabButton.visible = false
		$UI/Confirmation.visible = false
		
		# add photo functions, will probably need to thread load
		$UI/MenuAnimator.play("pawtrail")
		$UI/MenuAnimator.stop()
		$"UI/PawPrint Anim".visible = false
		$UI/Notification.visible = false
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_no_button_button_down():
	$UI/Confirmation/TitleText.visible = false
	$UI/Confirmation/CreateText.visible = false
	$UI/Confirmation/PlayText.visible = false
	$UI/Confirmation.visible = false
