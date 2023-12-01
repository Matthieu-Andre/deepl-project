#!/bin/bash
# Script to:
# 1. Prepare (if necessary) the inputs for the segmentation pipeline.
# 2. Execute the segmentation pipeline.
# 3. Glue back together (if necessary) the segmentation outputs.
# 4. Clean the segmentation results.
# Be sure to execute set_env.sh from this same folder.
# Parameters:
# Image_path: path to the .nii.gz original image file.
# Output_folder_path: Path to the folder where the .nii.gz files will be created.
# Outputs:
# - Depending on the input image, one or several .nii.gz images.
# - Parameters to reconstruct back the image given the smaller images. (it goes the same with the segmentations).
# Author: Sergio Daniel Hernandez Charpak

# Parameters
IMAGE_PATH=$1
OUTPUT_FOLDER_PATH=$(realpath ${2})

# Standard extension
EXT_FILES=".nii.gz"
# Standard contrast
CONTRAST="t2"
SCT_VERSION="5.6"
SCT_VERSION_5_6="5.6"
# Size of the box and cylinder and the outest segmented structure depends on the tissue segmented.
# Size which should contain the spinal canal or the vertebrae.
SIZE_CYLINDER="35mm"
# Max size (in voxels) for the masks in the z axis
MAX_Z_SIZE="700"

# HERE YOU DEFINE THE FOLDER PATHS WHERE YOU HAVE THE SCRIPTS 
# convert_back_segs, re_shape_masks
# and the script you will make to segment. 
ROOT_SCRIPT_FOLDER=$ROOT_ROOT_SEG
ROOT_PREPOST_SCRIPT_FOLDER=$ROOT_PREPOST_SEG
ROOT_CLEAN_SCRIPTS=$ROOT_CLEAN_SEG

# TMP Files folder
TMP_FOLDER=$OUTPUT_FOLDER_PATH"/""TMP_FOLDER"
# Creating folders
mkdir -p $OUTPUT_FOLDER_PATH
mkdir -p $TMP_FOLDER

# Naming variables
f_no_ext=$(basename -s $EXT_FILES $IMAGE_PATH)
image_path_folder=$(dirname $IMAGE_PATH)

# Step 1. Detect the centerline
# For the sct_get_centerline output you do not need to specify the output extension apparently. (STC 5.4)
# Apparently for SCT 5.6 you do need to specify the output extension.
f_centerline=$f_no_ext"_centerline"
f_centerline_with_ext=$f_no_ext"_centerline"$EXT_FILES
f_centerline_path=$TMP_FOLDER"/"$f_centerline
f_centerline_with_ext_path=$TMP_FOLDER"/"$f_centerline_with_ext
if [ "$SCT_VERSION" == "$SCT_VERSION_5_6" ]; then
sct_get_centerline -i $IMAGE_PATH -c $CONTRAST -o $f_centerline_with_ext_path
else 
sct_get_centerline -i $IMAGE_PATH -c $CONTRAST -o $f_centerline_path
fi
# Step 2. Make a box mask using the centerline
f_box_mask_no_ext=$f_no_ext"_box_mask"
f_box_mask=$f_box_mask_no_ext$EXT_FILES
f_box_mask_path=$TMP_FOLDER"/"$f_box_mask
sct_create_mask -i $IMAGE_PATH -p centerline,$f_centerline_with_ext_path -size $SIZE_CYLINDER -f box -o $f_box_mask_path

# Step 3. Reshaping the masks before cropping the image. Theses masks will be later used to merge the segmentations.
folder_masks=$TMP_FOLDER"/masks"
masks_basename="box"
python $ROOT_PREPOST_SCRIPT_FOLDER"/re_shape_masks.py" -i $f_box_mask_path -max_z_voxels $MAX_Z_SIZE -ofolder $folder_masks -obasename $masks_basename

# Step 4. Cropping the original image using the created masks.
input_to_crop=$IMAGE_PATH
output_cropped_folder=$TMP_FOLDER"/cropped_imgs"
mkdir -p $output_cropped_folder
# Go through the masks created in the folder
masks_for_cropping=$TMP_FOLDER"/masks/"$masks_basename"*"$EXT_FILES
for mask_for_cropping in $masks_for_cropping
do
    mask_for_cropping_no_ext=$(basename -s $EXT_FILES $mask_for_cropping)
    cropped_name=$f_no_ext"_cropped_"$mask_for_cropping_no_ext$EXT_FILES
    cropped_output_path=$output_cropped_folder"/"$cropped_name
    sct_crop_image -i $input_to_crop -m $mask_for_cropping -o $cropped_output_path
done

# Step 5. Segmentation of the cropped images.
# Preparing the output_folder for the tmp segs
output_cropped_segs_folder=$TMP_FOLDER"/cropped_segs"
mkdir -p $output_cropped_segs_folder
# Gets the outputs of the cropping (e.g. the inputs for the segmentation)
inputs_for_segmentation=$output_cropped_folder"/*"$EXT_FILES
# These outputs will now go through the segmentation
for input_for_segmentation in $inputs_for_segmentation
do
    # THIS IS WHERE YOU WOULD DO YOUR SEGMENTATION
done

# Step 6. Once the segmentations are done. We bring them back to the uncropped space.
# Folder for the segmentations, in the uncropped space
output_uncropped_segs_folder=$TMP_FOLDER"/uncropped_segs"
mkdir -p $output_uncropped_segs_folder
# There should be one seg per mask.
masks_used_for_cropping=($masks_for_cropping)
output_cropped_segs_files_tmp=$output_cropped_segs_folder"/*"$EXT_FILES
output_cropped_segs_files=($output_cropped_segs_files_tmp)
n_cropped_segs=${#output_cropped_segs_files[@]}
n_masks=${#masks_used_for_cropping[@]}
# Loop to check
for (( i=0; i<$n_masks; i++ ));
do
    mask_i="${masks_used_for_cropping[$i]}"
    mask_i_no_ext=$(basename -s $EXT_FILES $mask_i)
    flag_mask_i=0
    for (( j=0; j<$n_cropped_segs; j++ ));
    do
        if [[ $flag_mask_i == 0 ]]; then
            cropped_seg_j="${output_cropped_segs_files[$j]}"
            cropped_seg_j_no_ext=$(basename -s $EXT_FILES $cropped_seg_j)
            if [[ "$cropped_seg_j_no_ext" == *"$mask_i_no_ext"* ]]; then
                uncropped_seg_j_name=$cropped_seg_j_no_ext"_norm"$EXT_FILES
                python $ROOT_PREPOST_SCRIPT_FOLDER"/convert_back_segs.py" -i $cropped_seg_j -t $mask_i -o $output_uncropped_segs_folder"/"$uncropped_seg_j_name
                flag_mask_i=1
            fi
        fi
    done

done

# Step 7. Now that the segmentations are back to the uncropped space. Just need to add them together to get the ginal segmentation.
output_seg_folder=$OUTPUT_FOLDER_PATH
output_seg_name=$f_no_ext"_seg"$EXT_FILES
output_seg=$output_seg_folder"/"$output_seg_name
output_uncropped_segs_files_tmp=$output_uncropped_segs_folder"/*"$EXT_FILES
output_uncropped_segs_files=($output_uncropped_segs_files_tmp)
n_uncropped_segs=${#output_uncropped_segs_files[@]}
# Sums all to the first one.
first_seg="${output_uncropped_segs_files[0]}"
cp $first_seg $output_seg
for (( i=1; i<$n_uncropped_segs; i++ ));
do
    uncropped_seg_i="${output_uncropped_segs_files[$i]}"
    sct_maths -i $output_seg -add $uncropped_seg_i -o $output_seg
done
