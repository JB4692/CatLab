extends Node2D

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
	var num_lines: int = int(file.get_line())
	var game_objects: Array = []
	print("Number of lines to read: " + str(num_lines))
	for i in range(0, num_lines):
		if file.eof_reached():
			print("Unexpected EOF reached! Closing file.")
			file.close()
			return -1
		var line = file.get_line()
		game_objects.append(parse_line(line))
	place_object(game_objects)
	
	file.close()
	return 0

func parse_line(line: String) -> Array:
	var split_line = line.split(",")
	# make more logic to be able to connect the objects to words in the game_save
	return split_line

# obj_array is a 2D array of game objects of form:
# object_name,x,y 
func place_object(obj_array: Array) -> void:
	print(obj_array)
	for i in range(0, len(obj_array)):
		match obj_array[i][0]:
			"josh":
				print("Found josh")
			"jane":
				print("found jane")
			"kamron":
				print("found kamron")
			"patricia":
				print("found patricia")
