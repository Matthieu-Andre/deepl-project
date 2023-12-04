#import sct_utils as sct
import sct
import os

image_folder = "../data/images/"
label_folder = "../data/labels"
processed_folder = "../data/processed/"

for image in os.listdir(image_folder):
    image_path = os.path.join(image_folder, image)
    label_path = os.path.join(label_folder, image.replace('_0000', ''))

    #get the centerline of the spinal cord
    centerline = sct.run("sct_get_centerline -i {}".format(image_path))

    #fix where to store the cropped image and label
    cropped_image = os.path.join(processed_folder, 'cropped_', image)
    cropped_label = os.path.join(processed_folder, 'cropped_label', image)

    #crop the image 
    sct.run("sct_extract_metric -i {} -size {} -f {} -o {}".format(image_path, '35mm', centerline_data, cropped_image))
    #crop the label
    sct.run("sct_extract_metric -i {} -size {} -f {} -o {}".format(label_path, '35mm', centerline_data, cropped_label))

    #resize the images to make them smaller 
    cropped_resampled_image = os.path.join(processed_folder, 'small_cropped_', image)
    cropped_resampled_label = os.path.join(processed_folder, 'small_cropped_label', image)

    sct.run("sct-resample -i {} -mm {} -o {}".format(cropped_image, '0.5x0.5x0.5', cropped_resampled_image))
    sct.run("sct-resample -i {} -mm {} -o {}".format(cropped_label, '0.5x0.5x0.5', cropped_resampled_label))
