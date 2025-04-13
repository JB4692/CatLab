extends CharacterBody2D

# https://www.youtube.com/watch?v=P02PcfgqrY8&ab_channel=GameDevKnight


var speed = 100.0
var jump_velocity = -400.0
var attack = false
var resume_attack = false
var direction = -1
var move_timer

var player_position = 0
var player
@onready var raycast_right = get_node("RayCast2D to Right")
@onready var raycast_left = get_node("RayCast2D to Left")
@onready var rc_left_timer = get_node("RayCast to Left for Timer")
@onready var rc_right_timer = get_node("RayCast to Right for Timer")

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	move_timer = $AttackTimer
	move_timer.wait_time = 0.1

func _on_attack_timer_timeout() -> void: # When timer stops 
	#print("Enemy timer stopped")
	# When timer stops, allow enemy to attack again 
	if resume_attack == true: 
		attack = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if raycast_right.is_colliding():
		direction = 1
	if raycast_left.is_colliding():
		direction = -1

	player_position = player.position
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# If this smaller raycast is colliding with player, 
	# stop enemy movement for a second 
	if rc_left_timer.is_colliding() || rc_right_timer.is_colliding():
		if move_timer.is_stopped():
			attack = false
			resume_attack = true
			move_timer.start()
	
	if attack: 
		velocity.x = direction * speed 
	else: 
		velocity.x = 0

	move_and_slide()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	# When enemy is hit from the top, turn red and DIE 
	# print("Hit from top")
	player.jump("Bounce")
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
		#print("Start attacking player")
		attack = true


func _on_area_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		#print("Stop attacking player")
		attack = false
