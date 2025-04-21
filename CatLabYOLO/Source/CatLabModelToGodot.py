
import cv2
import asyncio
import websockets
import base64
from roboflow import Roboflow
import csv
import json
import os
from keys import ROBOFLOW_API_KEY


# YOLO Model Paths
CFG_PATH = "yolov4.cfg"
WEIGHTS_PATH = "yolov4.weights"
NAMES_PATH = "cards.names"

# Load YOLO Model
print("Loading YOLO model...")
net = cv2.dnn.readNet(WEIGHTS_PATH, CFG_PATH)

# Check for CUDA availability
print("Checking for CUDA Enabled Devices...")
cuda_available = cv2.cuda.getCudaEnabledDeviceCount() > 0

if cuda_available:
    print("CUDA is available! Using GPU.")
    net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
    net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
else:
    print("CUDA is not available. Using CPU.")
    net.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCV)
    net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)

# Load class labels
with open(NAMES_PATH, "r") as f:
    classes = [line.strip() for line in f.readlines()]

# Get YOLO output layers
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers().flatten()]

def draw_predictions(image, predictions):
    output_img = image.copy()
    
    for pred in predictions['predictions']:
        # Get bounding box coordinates and class information
        x = int(pred['x'])
        y = int(pred['y'])
        width = int(pred['width'])
        height = int(pred['height'])
        label = pred['class']
        confidence = pred['confidence']
        
        # Calculate top-left and bottom-right points
        x1 = int(x - width/2)
        y1 = int(y - height/2)
        x2 = int(x + width/2)
        y2 = int(y + height/2)
        
        # Draw rectangle and label on the image
        cv2.rectangle(output_img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        text = f"{label}: {confidence:.2f}"
        cv2.putText(output_img, text, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    return output_img


def save_to_csv(image_objects):
    script_path = os.path.dirname(__file__)
    full_path = os.path.join(script_path, 'saves/current_objects.csv')
    with open(full_path, mode="w", newline="") as file:
        writer = csv.writer(file)
        for obj in image_objects:
            writer.writerow([obj["label"], obj["x"], obj["y"], obj["width"], obj["height"]])
    print("Current frame saved to 'Source/saves/current_objects.csv'.")

async def send_video(websocket, path=None):
    
    rf = Roboflow(api_key=ROBOFLOW_API_KEY)
    project = rf.workspace().project("catlab-level-recognition-model")
    model = project.version(4).model
    last_response = None

    cap = cv2.VideoCapture(0)  # Open webcam
    if not cap.isOpened():
        print("Error: Unable to access the webcam.")
        return
    print("Starting video capture. Press 'ENTER' to save the current detections.")

    try:
        while True:
            # # Encode the image
            ret, frame = cap.read()
            if not ret:
                print("Failed to grab frame")
                break

            frame = cv2.resize(frame, (1152, 648))
            
            # Get detections (Assuming 'model' is already initialized)
            predictions = model.predict(frame, confidence=40, overlap=30).json()
            
            # Extract only the objects visible in the current frame
            frame_objects = []
            for obj in predictions['predictions']:
                frame_objects.append({
                    "label": obj["class"],
                    "confidence": obj["confidence"],
                    "x": obj["x"],
                    "y": obj["y"],
                    "width": obj["width"],
                    "height": obj["height"]
                })

            # Draw detections on the frame
            output_frame = draw_predictions(frame, predictions)

            # Display the frame (If GUI is supported)
            # cv2.imshow('Object Detection', output_frame)

            # # User input handling
            # key = cv2.waitKey(1) & 0xFF

            # if key == ord('s'):
            #     save_to_csv(frame_objects)
            # if key == ord('q'):
            #     break

            # time.sleep(0.1)
            _, buffer = cv2.imencode('.jpg', output_frame, [cv2.IMWRITE_JPEG_QUALITY, 50])
            encoded_frame = base64.b64encode(buffer).decode("utf-8")
            
            
            # Send frame to WebSocket client (Godot)
            await websocket.send(encoded_frame)
            # print(f"Sent frame: {len(encoded_frame)} bytes")
            try:
                response = await asyncio.wait_for(websocket.recv(), timeout=0.01)
                if isinstance(response, bytes):
                    response = response.decode('utf-8')
                

                if last_response != response:
                    print(f"Received response from Godot: {response}")
                    print(f"Received as last_response: {last_response}")
                    if response == 'SAVE':
                        save_to_csv(frame_objects)
                        last_response = None
                    elif response == 'QUIT':
                        print(f"Received {response}. Ending image transmission.")
                        break

                    last_response = response

            except asyncio.TimeoutError:
                pass
            except websockets.exceptions.ConnectionClosed as e:
                print(f"Connection closed: {e}")
                break

            await asyncio.sleep(1/60)  # 30 FPS

    except Exception as e:
        print(f"Error: {e}")
    finally:
        cap.release()  # Release webcam when done


async def main():
    # Start WebSocket server
    async with websockets.serve(send_video, "127.0.0.1", 8080, max_size=2**20):
        print("WebSocket Server started on ws://127.0.0.1:8080")
        await asyncio.Future()  # Keep server running


if __name__ == "__main__":
    asyncio.run(main())
