extends Area2D

signal coin_collected

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#print("Player entered coin")
		emit_signal("coin_collected")
		queue_free()
