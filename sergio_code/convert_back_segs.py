# -*- coding: utf-8 -*-
"""
Merging 3D volumes of different dims but from the same
anatomical reference.
It uses the masks used to crop the image to shape them in order to bring
them back to the original dims.
Saves its results as a different .nii.gz file.

@author: Sergio Daniel Hernandez Charpak
"""

import numpy as np
import nibabel as nib
import os
import sys, getopt


def main(argv):
    verbose=1

    input_img='none'
    target_img='none'
    output_img='none'

    for a in range(len(argv)):
        if argv[a] == '-h':
            print('merge_images.py -i <imagetoresize> -t <targetsizeimage> -o <outputimage>')
            sys.exit()
        elif argv[a] == "-i":
            input_img = argv[a+1]
        elif argv[a] == "-t":
            target_img = argv[a+1]
        elif argv[a] == "-o":
            output_img = argv[a+1]
    if verbose:
        print("output_img",output_img)
        print("input_img",input_img)
        print("target_img",target_img)

    if output_img=='none' or input_img=='none' or target_img=='none':
        print('merge_images.py -i <imagetoresize> -t <targetsizeimage> -o <outputimage>')
        sys.exit()

    merge_images(input_img, target_img, output_img)

def merge_images(input_img,target_img,output_img, verbose=0):
    """
    Merging 3D volumes of different dims but from the same
    anatomical reference.
    It uses the masks used to crop the image to shape them in order to bring
    them back to the original dims.
    Loads the images.
    The target image is the mask used for the cropping. 
    Computes the min,max for x,y,z for that mask to get the positions
    to insert the input image data in that space.
    Parameters:
    input_img String path to the input image (segmentation).
    target_img String path to the target image (original mask).
    output_img String path to the output image (segmentation in the original mask space).
    """
    input_image = nib.load(input_img)
    input_image_data=input_image.get_fdata()

    target_image = nib.load(target_img)
    target_image_data=target_image.get_fdata()
    # Computes the min x,y,z where the original mask is not 0.
    target_image_data_non_zero_indices=np.argwhere(target_image_data>0.5)
    target_image_z_axis_indices=target_image_data_non_zero_indices[:,2]
    target_image_x_axis_indices=target_image_data_non_zero_indices[:,0]
    target_image_y_axis_indices=target_image_data_non_zero_indices[:,1]
    target_image_x_min=np.min(target_image_x_axis_indices)
    target_image_x_max=np.max(target_image_x_axis_indices)+1
    target_image_y_min=np.min(target_image_y_axis_indices)
    target_image_y_max=np.max(target_image_y_axis_indices)+1
    target_image_z_min=np.min(target_image_z_axis_indices)
    target_image_z_max=np.max(target_image_z_axis_indices)+1
    # TODO - Checks to check that the dimensions checks out.
    # Shapes the output as the target
    target_image_size=np.shape(target_image_data)
    output_data = np.zeros(target_image_size)
    # Fills it up with the input_image_data (the segmentation)
    if verbose:
        print("target_image_data_non_zero_indices", np.shape(target_image_data_non_zero_indices)) 
        print("x_min",target_image_x_min)
        print("y_min",target_image_y_min)
        print("z_min",target_image_z_min)
        print("x_max",target_image_x_max)
        print("y_max",target_image_y_max)
        print("z_max",target_image_z_max)
        print("input_image_data",np.shape(input_image_data))

    output_data[target_image_x_min:target_image_x_max,target_image_y_min:target_image_y_max,target_image_z_min:target_image_z_max]=input_image_data[:,:,:]
    # Saves it
    output_image = nib.Nifti1Image(output_data, affine=target_image.affine, header=target_image.header)
    nib.save(output_image, output_img)

if __name__ == "__main__":
    main(sys.argv[1:]) 
