extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_climbable_wall_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player" && body.has_method("set_climbing"): 
		body.set_climbing(true)


func _on_climbable_wall_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player" && body.has_method("set_climbing"): 
		body.set_climbing(false)
