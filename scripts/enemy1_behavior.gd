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
	#print("Detection Area entered")
	#if area.get_parent().name == "Player":
		#attack = true
		#print("Start attacking")
		pass

func _on_area_detection_area_exited(area: Area2D) -> void:
	#if area.get_parent().name == "Player":
		#attack = false
		#print("Stop attacking")
		pass
		
func _on_area_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Start attacking player")
		attack = true


func _on_area_detection_body_exited(body: Node2D) -> void:
	print("Body exited")
	if body.name == "Player":
		print("Stop attacking player")
		attack = false
