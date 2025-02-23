extends Node2D

@onready var player = $Player
@onready var heartContainer = $"CanvasLayer/Heart Container"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heartContainer.setMaxHearts(player.health)	
	player.healthChanged.connect(heartContainer.reduceHeart)
	player.playerRevived.connect(heartContainer.setMaxHearts)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_revive_trigger_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player":
		var player = body.get_node("/root/Main Game/Player")
		player.set_dead(true)
		player.revive()
	
