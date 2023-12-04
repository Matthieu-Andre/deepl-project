image_folder="../data/images/"
label_folder="../data/labels"
processed_folder="../data/processed/"

for image in "$image_folder"/*; do
    image_path="$image"
    label_path="$label_folder/$(basename "$image" | sed 's/_0000//')"

    # Get the centerline of the spinal cord
    centerline=$(sct_get_centerline -i "$image_path")

    # Fix where to store the cropped image and label
    cropped_image="$processed_folder/cropped_$(basename "$image")"
    cropped_label="$processed_folder/cropped_label/$(basename "$image")"

    # Crop the image
    sct_extract_metric -i "$image_path" -size 35mm -f "$centerline" -o "$cropped_image"
    # Crop the label
    sct_extract_metric -i "$label_path" -size 35mm -f "$centerline" -o "$cropped_label"

    # Resize the images to make them smaller
    cropped_resampled_image="$processed_folder/small_cropped_$(basename "$image")"
    cropped_resampled_label="$processed_folder/small_cropped_label/$(basename "$image")"

    sct_resample -i "$cropped_image" -mm 0.5x0.5x0.5 -o "$cropped_resampled_image"
    sct_resample -i "$cropped_label" -mm 0.5x0.5x0.5 -o "$cropped_resampled_label"
done
