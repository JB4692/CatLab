extends CharacterBody2D

# TODO: improve on controls
# - make jumping feel better  
# - flip sprite based on movement direction
signal healthChanged 
signal playerRevived 

var SPEED = 300.0 # 300
var JUMP_VELOCITY = -350.0
var start_position = Vector2(-550, 209.9991)
var climbing = false
var dead = false
var health: int = 3;
@onready var animated_sprite = $AnimatedSprite2D

func set_climbing(climb: bool):
	climbing = climb

func _physics_process(delta: float) -> void:
	if climbing: _wall_climb(delta)
	else: _movement(delta)
	move_and_slide()

func revive(): 
	# put player back in start_position
	if dead: 
		position = start_position
		dead = false
		health = 3; 
		playerRevived.emit(health)

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	#if body.name == "Enemy1":
	if body.name.contains("Enemy"):
		print("Hitbox entered by body. curr Health: ", health)
		if health > 0:
			health = health - 1
			print("Emitting signal")
			healthChanged.emit()
		elif health == 0: 
			set_dead(true)
			revive()

func set_dead(d: bool):
	dead = d

func _movement(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY



	var direction := Input.get_axis("ui_left", "ui_right")
	# not moving = 0, to right = 1, to left = -1 
	
	# flip sprite according to direction
	if direction > 0: # facing right 
		animated_sprite.flip_h = false
	elif direction < 0: 
		animated_sprite.flip_h = true
		
	if is_on_floor():
		if direction == 0: 
			animated_sprite.play("idle")
		else: 
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _wall_climb(delta):
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction: velocity = direction * SPEED/2
	else: velocity = Vector2.ZERO


func _on_player_hitbox_area_entered(area: Area2D) -> void:
	#print(area.get_parent().name)
	print("Area entered hitbox")
	#if body.name == "Enemy1":
		#print(health)
		#if health > 0:
			#health = health - 1
		#elif health == 0: 
			#set_dead(true)
			#revive()
