extends Node

var websocket = WebSocketPeer.new()
var image_texture = ImageTexture.new()
var is_connected = false

func _ready():
	connect_to_server()
	
func _process(delta):
	if Input.is_key_pressed(KEY_ENTER):
		websocket.close()
	else:
		websocket.poll()
		get_image_data()
		#if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			#var packet = websocket.get_packet()
			#if packet:
				#print("Packet received! Size:", packet.size())  # Debugging output
				#var img_data = packet.get_string_from_utf8()
#
				## Convert Base64 to raw binary data
				#var raw_data = Marshalls.base64_to_raw(img_data)
				#var image = Image.new()
#
				## Try to load the image from the buffer
				#var result = image.load_jpg_from_buffer(raw_data)
#
				#if result == OK:
					#print("Image successfully loaded.")
					## Apply it to TextureRect
					#var image_texture = ImageTexture.new()
					#image_texture.set_image(image)  # Correct method for dynamic textures
					#$TextureRect.texture = image_texture
					#print("Texture applied to TextureRect.")
				#else:
					#print("Error loading image! Result:", result)

func connect_to_server():
	websocket.connect_to_url("ws://127.0.0.1:8080")

func get_image_data():
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var packet = websocket.get_packet()
		if packet:
			print("Packet received! Size:", packet.size())  # Debugging output
			var img_data = packet.get_string_from_utf8()

			# Convert Base64 to raw binary data
			var raw_data = Marshalls.base64_to_raw(img_data)
			var image = Image.new()

			# Try to load the image from the buffer
			var result = image.load_jpg_from_buffer(raw_data)

			if result == OK:
				print("Image successfully loaded.")
				# Apply it to TextureRect
				var image_texture = ImageTexture.new()
				image_texture.set_image(image)
				$TextureRect.texture = image_texture
				print("Texture applied to TextureRect.")
			else:
				print("Error loading image! Result:", result)
