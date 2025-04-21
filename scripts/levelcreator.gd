extends Node

var websocket = WebSocketPeer.new()
var image_texture = ImageTexture.new()
var is_connected = false

func _ready():
	#var path = "C:\\Users\\Josh Brown\\UFOnline\\2025\\Spring25\\Senior Project\\CatLab\\CatLabYOLO\\Source\\CatLabModelToGodot.py"
	#var args = []
	#var blocking = false
	#var pid = OS.execute(path, args, blocking)
	connect_to_server()
	
func _process(delta):
	if Input.is_key_pressed(KEY_ENTER):
		websocket.put_packet("SAVE".to_utf8_buffer())
	elif Input.is_key_pressed(KEY_ESCAPE):
		websocket.put_packet("QUIT".to_utf8_buffer())
	websocket.poll()
	get_image_data()

func connect_to_server():
	websocket.connect_to_url("ws://127.0.0.1:8080")

func get_image_data():
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var packet = websocket.get_packet()
		if packet:
			#print("Packet received! Size:", packet.size())
			var img_data = packet.get_string_from_utf8()
			var raw_data = Marshalls.base64_to_raw(img_data)
			var image = Image.new()
			var result = image.load_jpg_from_buffer(raw_data)

			if result == OK:
				#print("Image successfully loaded.")
				var image_texture = ImageTexture.new()
				image_texture.set_image(image)
				$TextureRect.texture = image_texture
				#print("Texture applied to TextureRect.")
			else:
				print("Error loading image! Result:", result)
