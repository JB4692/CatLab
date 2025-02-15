extends CharacterBody2D

# TODO: improve on controls
# - stop jumping from looking weird 
# - face the direction he's moving in

var SPEED = 300.0
var JUMP_VELOCITY = -350.0
var start_position = Vector2(-550, 209.9991)

var dead = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()



func revive(): 
	# put player back in start_position
	if dead: 
		position = start_position

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Enemy1":
		dead = true
		revive()
