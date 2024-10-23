import cv2
from ultralytics import YOLO  # Make sure Ultralytics YOLO is correctly installed.

model_path = "C:/Users/HUZEYFE/Desktop/navigating_glasses-main/yolov8x.pt"  # Adjust path as necessary
model = YOLO(model_path)

def predict(chosen_model, img, conf=0.5):
    results = chosen_model.predict(img, conf=conf)
    return results

def predict_and_detect(chosen_model, img, conf=0.1):
    results = predict(chosen_model, img, conf=conf)
    for result in results:
        for box in result.boxes:
            class_name = result.names[int(box.cls[0])]
            confidence = round(float(box.conf), 2)
            cv2.rectangle(img, (int(box.xyxy[0][0]), int(box.xyxy[0][1])),
                          (int(box.xyxy[0][2]), int(box.xyxy[0][3])), (255, 0, 0), 2)
            cv2.putText(img, f"{class_name} {confidence}",
                        (int(box.xyxy[0][0]), int(box.xyxy[0][1]) - 10),
                        cv2.FONT_HERSHEY_PLAIN, 1, (255, 0, 0), 1)
    return img, results

# MJPEG stream URL
stream_url = 'http://192.168.118.108/mjpeg/1'

# Initialize video capture with the MJPEG stream URL
cap = cv2.VideoCapture(stream_url, cv2.CAP_FFMPEG)

# Check if the video stream was opened successfully
if not cap.isOpened():
    print("Error: Unable to open video stream.")
    exit(1)

# Debug: print successful connection message
print("Successfully connected to the video stream.")

while True:
    success, img = cap.read()
    if not success:
        print("Error: Unable to fetch frame from the stream.")
        continue  # Skip processing if frame not fetched successfully

    # Process the image/frame with YOLO model for object detection
    result_img, detection_results = predict_and_detect(model, img, conf=0.6)

    # Debug: print the number of detections
    print(f"Number of detections: {len(detection_results)}")

    # Display the processed image
    cv2.imshow("Video", result_img)
    if cv2.waitKey(1) & 0xFF == ord('q'):  # Press 'q' to quit
        break

# Release the video capture and close all OpenCV windows
cap.release()
cv2.destroyAllWindows()

