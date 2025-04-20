extends Sprite2D

var speed := 10.0
var noise := FastNoiseLite.new()
var time := 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 0.1

func _process(delta):
	time += delta
	position.x += speed * delta
	position.y += noise.get_noise_1d(time) * 2.0
	
	if position.x > 1152 + 100:  
		position.x = -100
	elif position.x < -100:
		position.x = 1152 + 100
