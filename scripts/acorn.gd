extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300
var i = 0

func _ready() -> void:
	self.name = "acorn"

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_screen_exited() -> void:
	queue_free()
