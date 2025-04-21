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
var window_x = 1152
var window_y = 648
var score = 0

func _ready() -> void:
	#var file_to_read: String = "saves/save1.cfg"
	var file_to_read: String = "res://CatLabYOLO/Source/saves/current_objects.csv"
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
		var type_of_block = obj_array[i][0]
		var x_coord = int(obj_array[i][1])
		var y_coord = int(obj_array[i][2])
		var width = int(obj_array[i][3])
		var height = int(obj_array[i][4])
		match type_of_block:
			"Terrain":
				place_block(type_of_block, x_coord, y_coord, width, height)
			"Grass":
				place_block(type_of_block, x_coord, y_coord, width, height)
			"Brick":
				place_block(type_of_block, x_coord, y_coord, width, height)
			"Tower":
				#place_climbable_wall(x_coord, y_coord)
				place_tower(x_coord, y_coord, width, height)
			"Player":
				place_player(x_coord, y_coord, width, height)
			"Litter":
				place_litter_box(x_coord, y_coord, width, height)
			"Special":
				place_moving_platform(x_coord, y_coord, width, height)
			"Yarn":
				place_enemy(x_coord, y_coord, width, height)
			"Coin":
				place_coin(x_coord, y_coord)
			"Spray":
				place_sprayer(x_coord, y_coord)
			_:
				print("Could not match game object: ", obj_array[i][0])

func place_block(name: String, x: int, y: int, width: int, height: int) -> void:
	var dim = (width + height)/2
	#var dim = min(width, height)
	var pos = Vector2i(x - window_x/2, y - window_y/2)
	var block_scene = load("res://scenes/blocks/" + name.to_lower() + ".tscn")
	var block = block_scene.instantiate()
	block.position = pos
	block.get_node("Sprite2D").scale = Vector2(dim/32, dim/32)
	block.get_node("CollisionShape2D").scale = Vector2(dim/32, dim/32)
	main_game.add_child(block)
	
#func place_terrain(x: int, y: int, width: int, height: int) -> void:
	#var dirt_atlas_coord = Vector2i(0, 0)
	#var pixel_to_tile_coord = get_tile_from_position(Vector2(x, y))
	#platforms.set_cell(0, pixel_to_tile_coord, 0, dirt_atlas_coord, 0)

#func place_grass(x: int, y: int, width: int, height: int):
	#var dim = max(width, height)
	#var pos = Vector2i(x - window_x/2, y - window_y/2)
	#var grass_scene = load("res://scenes/blocks/grass.tscn")
	#var grass = grass_scene.instantiate()
	#grass.position = pos
	#grass.get_node("Sprite2D").scale = Vector2(dim/32, dim/32)
	#grass.get_node("CollisionShape2D").scale = Vector2(dim/32, dim/32)
	#main_game.add_child(grass)

#func place_brick(x: int, y: int) -> void:
	#var brick_atlas_coord = Vector2i(2,0)
	#var pixel_to_tile_coord = get_tile_from_position(Vector2(x, y))
	#platforms.set_cell(0, pixel_to_tile_coord, 0, brick_atlas_coord, 0)
	
func place_tower(x: int, y: int, width: int, height: int):
	var pos = Vector2i(x - window_x/2, y - window_y/2)
	var tower_scene = load("res://scenes/blocks/tower.tscn")
	var tower = tower_scene.instantiate()
	if tower:
		tower.position = Vector2i(x - window_x/2, y - window_y/2)
		tower.get_node("Sprite2D").scale = Vector2(width/32, height/32)
		#tower.get_node("Area2D/CollisionShape2D").scale = Vector2(width/32, height/32)
	main_game.add_child(tower)
	
#func place_climbable_wall(x: int, y: int) -> void:
	#var tile_size = 32
	#var climbable_wall_scene = load("res://scenes/blocks/climbable_wall.tscn")
	#var c_wall = climbable_wall_scene.instantiate()
	#c_wall.position = Vector2i(x * tile_size - window_x/2, y * tile_size - window_y/2)
	#c_wall.name = "climbable_wall" + str(num_climbable_walls)
	#num_climbable_walls += 1 
	#main_game.add_child(c_wall)

#player is placed via PIXEL positions
func place_player(x: int, y: int, width: int, height: int) -> void:
	var pos = Vector2i(x - window_x/2, y - window_y/2)
	player.set_start_position(pos)
	player.position = Vector2i(pos)
	player.scale = Vector2(2, 2)
	
func place_moving_platform(start_x: int, start_y: int, width: int, height: int) -> void:
	var distance = 100
	var linear_moving_platform_scene = load("res://scenes/blocks/moving_platform.tscn")
	var platform = linear_moving_platform_scene.instantiate()
	platform.position = Vector2i(start_x - window_x/2, start_y - window_y/2)
	platform.scale = Vector2(width/32, height/32)
	platform.name = "moving_platform" + str(num_moving_platforms)
	main_game.add_child(platform)
	var child = main_game.get_node("moving_platform" + str(num_moving_platforms))
	child.distance_x = distance
	num_moving_platforms += 1 

#coin in place for the litter box right now. 
#eol = end of level
func place_litter_box(x: int, y: int, width: int, height: int) -> void:
	var eol_scene = load("res://scenes/blocks/level_endpoint.tscn")
	var eol_object = eol_scene.instantiate()
	eol_object.position = Vector2i(x - window_x/2, y - window_y/2)
	eol_object.scale = Vector2(width/32, height/32)
	main_game.add_child(eol_object)
	
func place_enemy(x: int, y: int, width: int, height: int) -> void:
	var enemy_scene = load("res://scenes/enemies/dog.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2i(x - window_x/2, y - window_y/2)
	enemy.scale = Vector2(20, 20)
	enemy.name = "enemy" + str(num_enemies)
	main_game.add_child(enemy)
	num_enemies += 1

func place_coin(x: int, y: int) -> void:
	var coin_scene = load("res://scenes/items/coin.tscn")
	var coin = coin_scene.instantiate()
	coin.position = Vector2i(x - window_x/2, y - window_y/2)
	coin.name = "coin" + str(num_coins)
	coin.coin_collected.connect(_on_coin_collected)
	main_game.get_node("Coins").add_child(coin)
	num_coins += 1

func place_sprayer(x: int, y: int):
	var sprayer_scene = load("res://scenes/enemies/sprayer.tscn")
	var sprayer = sprayer_scene.instantiate()
	sprayer.position = Vector2i(x - window_x/2, y - window_y/2)
	main_game.add_child(sprayer)
	
	
# OTHER HELPER FUNCTIONS =======================================================
func round_places(num: float, places: int) -> float:
	return (round(num*pow(10, places))/pow(10, places))

func add_score(points: int):
	score += 1
	print("added to score")

func get_tile_from_position(global_position: Vector2):
	global_position.x -= window_x/2
	global_position.y -= window_y/2
	return platforms.local_to_map(platforms.to_local(global_position))

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.name.contains("Player"):
		get_tree().reload_current_scene()
