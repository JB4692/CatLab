extends Node2D

@onready var platforms: TileMap = $Platforms

func _ready() -> void:
	var file_to_read: String = "saves/save1.txt"
	if read_from_file(file_to_read) >= 0:
		print("Successfully loaded the game file!")
	else:
		print("Failed to read game file.")

func read_from_file(path: String) -> int:
	if not FileAccess.file_exists(path):
		print("Could not locate file.")
		return -1

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var game_objects: Array = []
	
	while !file.eof_reached():
		var line = file.get_line()
		if line == "":
			break
		game_objects.append(parse_line(line))
	print(game_objects)
	place_object(game_objects)
	
	file.close()
	return 0

func parse_line(line: String) -> Array:
	var split_line = line.split(",")
	return split_line

# obj_array is a 2D array of game objects of form:
# object_name,x,y 
#void set_cell(layer: int, 
#			   coords: Vector2i, 
#			   source_id: int = -1, 
#			   atlas_coords: Vector2i = Vector2i(-1, -1), 
#			   alternative_tile: int = 0)
func place_object(obj_array: Array) -> void:
	for i in range(len(obj_array)):
		var x_coord = int(obj_array[i][1])
		var y_coord = int(obj_array[i][2])
		
		match obj_array[i][0]:
			"grass":
				place_grass(x_coord, y_coord)
			"brick":
				place_brick(x_coord, y_coord)
			"player":
				var player = get_node("Player")
				if player:
					player.position = Vector2(0, 0)
				else:
					print("player doesn't exist yet")
			_:
				print("Could not match game object.")

func place_grass(x: int, y: int):
	var grass_atlas_coord = Vector2i(0,1)
	platforms.set_cell(0, Vector2i(x, y), 0, grass_atlas_coord, 0)

func place_brick(x: int, y: int):
	var brick_atlas_coord = Vector2i(2,0)
	platforms.set_cell(0, Vector2i(x, y), 0, brick_atlas_coord, 0)
