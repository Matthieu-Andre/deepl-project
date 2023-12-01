# -*- coding: utf-8 -*-
"""
Breaks down a given binary mask into several (if the former exeeds a z-axis size, in voxels).
Saves the resulting masks in a given folder.

@author: Sergio Daniel Hernandez Charpak
"""

import numpy as np
import nibabel as nib
import os
import sys, getopt


def main(argv):
    verbose=0

    input_img='none'
    max_z_size='none'
    output_folder='none'
    output_basename='none'
    for a in range(len(argv)):
        if argv[a] == '-h':
            print('re_shape_masks.py -i <masktobreakdown> -max_z_voxels <max_z_voxels> -ofolder <output_folder> -obasename <outputbasename')
            sys.exit()
        elif argv[a] == "-i":
            input_img = argv[a+1]
        elif argv[a] == "-max_z_voxels":
            max_z_size = np.int32(argv[a+1])
        elif argv[a] == "-ofolder":
            output_folder = argv[a+1]
        elif argv[a] == "-obasename":
            output_basename = argv[a+1]
    if verbose:
        print("max_z_size",max_z_size)
        print("input_img",input_img)
        print("output_folder",output_folder)
        print("output_basename",output_basename)

    if output_folder=='none' or input_img=='none' or max_z_size=='none' or output_basename=='none':
        print('re_shape_masks.py -i <masktobreakdown> -max_z_voxels <max_z_voxels> -ofolder <output_folder> -obasename <outputbasename')
        sys.exit()

    re_shape_masks(input_img, max_z_size, output_folder, output_basename, verbose)

def re_shape_masks(input_img, max_z_size, output_folder, output_basename, verbose=0):
    """
    Breaks down a given binary mask into several (if the former exeeds a z-axis size, in voxels).
    Saves the resulting masks in a given folder.
    Loads the image, compares its size to the max_z_size.
    If necessary, breaks it down into several masks.
    Then saves them in the given output folder.
    Parameters:
    input_img String path to the input image.
    max_z_size int maximum size for a mask
    output_folder String path to the output folder.
    output_basename String basename for the created masks, with no extension
    """
    # Loading the data
    input_image = nib.load(input_img)
    input_image_data=input_image.get_fdata()
    input_image_size=np.shape(input_image_data)
    # Preparing the output, array of nib images
    output_images=[]
    # Creates the output_folder
    os.makedirs(output_folder,exist_ok=True)
    # Comparing its size to the given size (z-axis)
    input_image_z_size=input_image_size[-1]
    if input_image_z_size <= max_z_size:
        # Nothing to do, saves it to the output folder 
        output_images.append(input_image)
    else:
        # Needs to breakdown the mask
        n_masks_to_create = np.int32(np.ceil(input_image_z_size/max_z_size))
        current_start = 0
        for i in range(n_masks_to_create):
            z_start = current_start
            z_finish = current_start + max_z_size
            if z_finish >= input_image_z_size:
                # It's the last one, it's the modulo
                z_finish = current_start + input_image_z_size%max_z_size
            output_mask_i_data = np.zeros(input_image_size)
            output_mask_i_data[:,:,z_start:z_finish] = input_image_data[:,:,z_start:z_finish]
            output_image_i = nib.Nifti1Image(output_mask_i_data, affine=input_image.affine, header=input_image.header)
            output_images.append(output_image_i)
            current_start=z_finish
    # Preparing to save the output_masks
    n_masks_to_save = len(output_images)
    for i_mask_to_save in range(n_masks_to_save):
        mask_to_save = output_images[i_mask_to_save]
        name_mask = output_basename+"_mask_"+str(i_mask_to_save)+".nii.gz"
        path_mask = os.path.join(output_folder,name_mask)
        nib.save(mask_to_save, path_mask)
if __name__ == "__main__":
    main(sys.argv[1:]) 
