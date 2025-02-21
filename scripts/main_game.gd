extends Node2D

@onready var main_game: Node2D = $"."
@onready var platforms: TileMap = $Platforms
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var file_to_read: String = "saves/save1.cfg"
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

func place_object(obj_array: Array) -> void:
	for i in range(len(obj_array)):
		var x_coord = int(obj_array[i][1])
		var y_coord = int(obj_array[i][2])
		
		match obj_array[i][0]:
			"grass1":
				place_grass1(x_coord, y_coord)
			"grass2":
				place_grass2(x_coord, y_coord)
			"grass3":
				place_grass3(x_coord, y_coord)
			"brick":
				place_brick(x_coord, y_coord)
			"player":
				place_player(x_coord, y_coord)
			"litter_box":
				place_litter_box(x_coord, y_coord)
			"moving_platform":
				var distance = int(obj_array[i][3])
				place_moving_platform(x_coord, y_coord, distance)
			"enemy1":
				place_enemy1(x_coord, y_coord)
			"climbable_wall":
				place_climbable_wall(x_coord, y_coord)
			"coin":
				pass
			_:
				print("Could not match game object.")

#tile are placed via TILE GRID positions
func place_grass1(x: int, y: int) -> void:
	var grass_atlas_coord = Vector2i(0,1)
	platforms.set_cell(0, Vector2i(x, y), 0, grass_atlas_coord, 0)

func place_grass2(x: int, y: int) -> void:
	var grass_atlas_coord = Vector2i(0,1)
	platforms.set_cell(0, Vector2i(x, y), 0, grass_atlas_coord, 0)
	platforms.set_cell(0, Vector2i(x+1,y), 0, grass_atlas_coord,0)

func place_grass3(x: int, y: int):
	var grass_atlas_coord = Vector2i(0,1)
	platforms.set_cell(0, Vector2i(x, y), 0, grass_atlas_coord, 0)
	platforms.set_cell(0, Vector2i(x+1,y), 0, grass_atlas_coord,0)
	platforms.set_cell(0, Vector2i(x+2,y), 0, grass_atlas_coord,0)

func place_brick(x: int, y: int) -> void:
	var brick_atlas_coord = Vector2i(2,0)
	platforms.set_cell(0, Vector2i(x, y), 0, brick_atlas_coord, 0)

func place_climbable_wall(x: int, y: int) -> void:
	var tile_size = 32
	var climbable_wall_scene = load("res://scenes/climbable_wall.tscn")
	var cw_object = climbable_wall_scene.instantiate()
	cw_object.position = Vector2i(x * tile_size, y * tile_size)
	main_game.add_child(cw_object)

#player is placed via PIXEL positions
func place_player(x: int, y: int) -> void:
	player.position = Vector2i(x, y)
	
func place_moving_platform(start_x: int, start_y: int, distance: int) -> void:
	var linear_moving_platform_scene = load("res://scenes/moving_platform.tscn")
	var platform_object = linear_moving_platform_scene.instantiate()
	platform_object.position = Vector2i(start_x, start_y)
	
	main_game.add_child(platform_object)
	var child = main_game.get_node("moving_platform")
	child.distance_x = distance

#coin in place for the litter box right now. 
#eol = end of level
func place_litter_box(x: int, y: int) -> void:
	var eol_scene = load("res://scenes/level_endpoint.tscn")
	var eol_object = eol_scene.instantiate()
	eol_object.position = Vector2i(x, y)
	main_game.add_child(eol_object)
	
func place_enemy1(x: int, y: int) -> void:
	var enemy1_scene = load("res://scenes/enemy1.tscn")
	var e1_object = enemy1_scene.instantiate()
	e1_object.position = Vector2i(x, y)
	main_game.add_child(e1_object)
	
func place_coin(x: int, y: int) -> void:
	pass
