extends HBoxContainer

@onready var heart = preload("res://scenes/heart.tscn")
@onready var children = get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setMaxHearts(max: int):
	# Make sure heart_container has no children		
	if get_children().size() != 0:
		for i in get_children().size():
			reduceHeart() 
	
	for i in range(3): # replaced range(max) with 3
		var h = heart.instantiate()
		add_child(h)


func reduceHeart():
	if(get_children().size() > 0):
		#children[get_children().size()].free()
		get_children()[get_children().size() - 1 ].queue_free()
	
func increaseHeart():
	var h = heart.instantiate()
	add_child(h)
