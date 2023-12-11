# deepl-project

# Structure ( feel free to change )
* **sergio_code**: the 3 scripts that Sergio gave us
* **nnUNet**: the cloned nnunet repo ( should not be pushed, added to gitignore)
* **data**: folder containing all the data should all be in .gz
    * **raw_labels**: labeled data of the patients
    * **raw_images**: mri scans 
* **scripts** contains scripts
    * **create_dataset.py**: creates dataset from the data, run it from the scripts format with `python create_dataset.py`
* **set_env.sh**: sets the environment variables needed

# Setup:
* Create a new environment with python version 3.10: conda create -n dlb python=3.10
* after cloning ( or if nnUNet submodule is empty ) run : `git submodule update --init --recursive`
* download sct: https://spinalcordtoolbox.com/user_section/installation.html
    * in our case we used the 6.1 version
* install the correct version of pytorch for your computer: https://pytorch.org/get-started/locally/
* pip install nnUNetv2

# Preprocess data
To run this command on new data, it must follow the following structure : 
* in a `raw_images` folder, you should have all your images with the following nomenclature `your_image_0000.nii.gz` 
* in a `raw_labels` folder, you should have all your labels with the following nomenclature `your_image.nii.gz` for the label corresponding to this image `your_image_0000.nii.gz` 

When this step is validated, to run the pre processing :
* go to folder scripts
* run bash cropping.sh
This command creates two folders `labels` and `images` that contain the cropped and down-sampled data.

# HOW TO RUN (everything in terminal)
* Run `source set_env.sh` to set the local variables ( needs to be run each time a terminal is opened )
* Run `python create_dataset.py`
* Run nnUNetv2_plan_and_preprocess -d 1 --verify_dataset_integrity
* Run nnUNetv2_train 1 3d_fullres all -num_gpus 3 (of course, change to the number of GPU you have)
