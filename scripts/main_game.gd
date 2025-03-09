extends Node2D

@onready var main_game: Node2D = $"."
@onready var platforms: TileMap = $Platforms
@onready var player: CharacterBody2D = $Player
@onready var timer: Timer = $Timer
@onready var time_label: Label = $TimerLabel
@onready var score_label: Label = $ScoreLabel

@onready var heartContainer = $"CanvasLayer/Heart Container"

signal time_ran_out

# num_object variables are for number of objects of that type on the screen
# this is for naming them uniquely 
var num_enemies = 0
var num_climbable_walls = 0
var num_moving_platforms = 0
var num_coins = 0

var score = 0

func _ready() -> void:
	var file_to_read: String = "saves/save1.cfg"
	load_from_file_on_start(file_to_read)
	heartContainer.setMaxHearts(player.health)	
	player.healthChanged.connect(heartContainer.reduceHeart)
	player.playerRevived.connect(heartContainer.setMaxHearts)



func _process(delta: float) -> void:
	time_label.text = "Time left: " + str(round_places(timer.time_left, 2))
	score_label.text = "Score: " + str(score)

func _on_countdown_timer_timeout() -> void:
	# add killing/resetting the game here. 
	get_tree().change_scene_to_file("res://scenes/end_of_level.tscn")
	print("Time ran out! You lose!")

func _on_coin_collected():
	score += 1
	print("Coin collected!")

func _on_revive_trigger_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player":
		var player = body.get_node("/root/Main Game/Player")
		player.set_dead(true)
		player.revive()

func load_from_file_on_start(path: String) -> void:
	if read_from_file(path) >= 0:
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
	#print(game_objects)
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
			"dirt":
				place_dirt(x_coord, y_coord)
			"grass":
				var length = int(obj_array[i][3])
				place_grass(x_coord, y_coord, length)
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
				place_coin(x_coord, y_coord)
			_:
				print("Could not match game object.")

#tile are placed via TILE GRID positions\
func place_dirt(x: int, y: int) -> void:
	var dirt_atlas_coord = Vector2i(0, 0)
	platforms.set_cell(0, Vector2i(x, y), 0, dirt_atlas_coord, 0)
	
func place_grass(x: int, y: int, length: int) -> void:
	var grass_atlas_coord = Vector2i(0,1)
	for i in range(0, length):
		platforms.set_cell(0, Vector2i(x + i, y), 0, grass_atlas_coord, 0)


func place_brick(x: int, y: int) -> void:
	var brick_atlas_coord = Vector2i(2,0)
	platforms.set_cell(0, Vector2i(x, y), 0, brick_atlas_coord, 0)

func place_climbable_wall(x: int, y: int) -> void:
	var tile_size = 32
	var climbable_wall_scene = load("res://scenes/climbable_wall.tscn")
	var c_wall = climbable_wall_scene.instantiate()
	c_wall.position = Vector2i(x * tile_size, y * tile_size)
	c_wall.name = "climbable_wall" + str(num_climbable_walls)
	num_climbable_walls += 1 
	main_game.add_child(c_wall)

#player is placed via PIXEL positions
func place_player(x: int, y: int) -> void:
	player.position = Vector2i(x, y)
	
func place_moving_platform(start_x: int, start_y: int, distance: int) -> void:
	var linear_moving_platform_scene = load("res://scenes/moving_platform.tscn")
	var platform = linear_moving_platform_scene.instantiate()
	platform.position = Vector2i(start_x, start_y)
	platform.name = "moving_platform" + str(num_moving_platforms)
	main_game.add_child(platform)
	var child = main_game.get_node("moving_platform" + str(num_moving_platforms))
	child.distance_x = distance
	num_moving_platforms += 1 

#coin in place for the litter box right now. 
#eol = end of level
func place_litter_box(x: int, y: int) -> void:
	var eol_scene = load("res://scenes/level_endpoint.tscn")
	var eol_object = eol_scene.instantiate()
	eol_object.position = Vector2i(x, y)
	main_game.add_child(eol_object)
	
func place_enemy1(x: int, y: int) -> void:
	var enemy1_scene = load("res://scenes/enemy1.tscn")
	var enemy = enemy1_scene.instantiate()
	enemy.position = Vector2i(x, y)
	enemy.name = "enemy" + str(num_enemies)
	main_game.add_child(enemy)
	num_enemies += 1
	
func place_coin(x: int, y: int) -> void:
	var coin_scene = load("res://scenes/coin.tscn")
	var coin = coin_scene.instantiate()
	coin.position = Vector2i(x, y)
	coin.name = "coin" + str(num_coins)
	coin.coin_collected.connect(_on_coin_collected)
	main_game.get_node("Coins").add_child(coin)
	num_coins += 1

func round_places(num: float, places: int) -> float:
	return (round(num*pow(10, places))/pow(10, places))

func add_score(points: int):
	score += 1
	print("added to score")
