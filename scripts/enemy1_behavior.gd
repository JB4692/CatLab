extends CharacterBody2D

# https://www.youtube.com/watch?v=P02PcfgqrY8&ab_channel=GameDevKnight


var speed = 100.0
var jump_velocity = -400.0
var attack = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if attack: 
		velocity.x = -1 * speed 
	
	if not attack: 
		velocity.x = 0

	move_and_slide()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	# When enemy is hit from the top, turn red and DIE 
	print("Hit from top")
	queue_free()
	
func _on_area_2d_area_exited(_area: Area2D) -> void:
	pass

# If PLAYER enters certain distance from Enemy1, 
# Enemy start attacking 
func _on_area_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Player":
		attack = true
		print("Start attacking")

func _on_area_detection_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Player":
		attack = false
		print("Stop attacking")
	
