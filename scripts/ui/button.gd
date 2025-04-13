extends Button

const NORMAL_COLOR = Color(1, 1, 1)  
const HOVER_COLOR = Color(0.8, 0.8, 0.8)



func _ready():
	self.modulate = NORMAL_COLOR
	
func _on_mouse_entered():
	self.modulate = HOVER_COLOR

func _on_mouse_exited():
	self.modulate = NORMAL_COLOR
