import cv2
import os
import random

# Instructions:
# Pass in the image of the card you would like to augment and this will generate 100 augmentations of it rotated and flipped in different ways
# -> These augmented files should be outputted into the images folder within the database
# Example usage
# augment_image("card_image.jpg", "augmented_images")

def augment_image(image_path, output_dir, num_images=100):
    # Read the image
    img = cv2.imread(image_path)

    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Generate augmented images
    for i in range(num_images):
        # Rotate image randomly within a range
        angle = random.randint(-30, 30)  # Rotate by up to ±30 degrees
        rotated = rotate_image(img, angle)
        
        # Random vertical flip
        if random.choice([True, False]):
            flipped = cv2.flip(rotated, 0)  # Flip upside down
        else:
            flipped = rotated

        # Save the augmented image
        cv2.imwrite(os.path.join(output_dir, f"augmented_{i}.jpg"), flipped)

def rotate_image(image, angle):
    # Get image size
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)

    # Rotation matrix
    matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(image, matrix, (w, h))

    return rotated
    