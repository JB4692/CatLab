from roboflow import Roboflow
import cv2
import time
import csv

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

rf = Roboflow(api_key="")
project = rf.workspace().project("catlab-level-recognition-model")
model = project.version(4).model

print("Roboflow model loaded successfully!")

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    raise Exception("Could not open video device")

print("Starting video capture. Press 's' to save the current detections. Press 'q' to exit.")

while True:
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
    cv2.imshow('Object Detection', output_frame)

    # User input handling
    key = cv2.waitKey(1) & 0xFF

    if key == ord('s'):
        with open("current_objects.csv", mode="w", newline="") as file:
            writer = csv.writer(file)
            for obj in frame_objects:
                writer.writerow([obj["label"], obj["x"], obj["y"], obj["width"], obj["height"]])
        print("Current frame saved to 'current_objects.csv'.")

    if key == ord('q'):
        break

    time.sleep(0.1)  # Reduce API calls and CPU usage

cap.release()
cv2.destroyAllWindows()
