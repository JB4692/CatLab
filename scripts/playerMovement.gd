extends CharacterBody2D

# TODO: improve on controls
# - make jumping feel better  
# - flip sprite based on movement direction
signal healthChanged 
signal playerRevived 

var speed = 300.0 # 300
var JUMP_VELOCITY = -350.0
var start_position
var climbing = false
var dead = false
var health: int = 3;
var direction = 0
var is_flashing = false
@onready var animated_sprite = $AnimatedSprite2D

func get_speed():
	return speed

func set_climbing(climb: bool):
	climbing = climb

func _physics_process(delta: float) -> void:
	if climbing: _wall_climb(delta)
	else: _movement(delta)
	move_and_slide()

func revive(): # put player back in start_position
	if dead: 
		position = start_position
		dead = false
		health = 3; 
		playerRevived.emit(health)

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.name.contains("enemy"):
		animated_sprite.animation = "flash"
		is_flashing = true
		healthUpdate(1)

func set_dead(d: bool):
	dead = d

func jump(jump_type):
	if jump_type == "Bounce": # Only do a bit if bouncing off enemy
		velocity.y = JUMP_VELOCITY + 150
	else: 
		velocity.y = JUMP_VELOCITY

func _movement(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump("Input")

	direction = Input.get_axis("ui_left", "ui_right")
	# not moving = 0, to right = 1, to left = -1 
	
	# flip sprite according to direction
	if direction > 0: # facing right 
		animated_sprite.flip_h = false
	elif direction < 0: 
		animated_sprite.flip_h = true
	
	if not is_flashing: 
		if is_on_floor():
			if direction == 0: 
				animated_sprite.play("idle")
			else: 
				animated_sprite.play("walk")
		else:
			animated_sprite.play("jump")
	else:
		is_flashing = false
	
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func _wall_climb(delta):
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction: velocity = direction * speed/2
	else: velocity = Vector2.ZERO
	
	animated_sprite.play("climb")

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.name.contains("acorn"):
		print("Hit by acorn.")
		healthUpdate(1)

func healthUpdate(amount: int):
	health -= amount;
	if health > 0:
		#health = health - amount
		healthChanged.emit()
	elif health == 0: 
		set_dead(true)
		revive()

func set_start_position(pos: Vector2i):
	start_position = pos
