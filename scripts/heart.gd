extends Panel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update(b: bool):
	CanvasItem.visible = false 

#func setVisible(b: bool):
	#CanvasItem.Visible = b
