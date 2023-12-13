# Deep learning framework for automatic detection and segmentation of bending artefact in MRI volumes of the spinal cord
## CS-502 : Deep Learning in biomedicine - Project December 2023
### Aline Brunner, Matthieu André, Louise Font, supervision by Sergio Hernandez Charpak

## Structure
* **nnUNet**: the cloned nnUNet repository that contains all the model structure
* **data**: folder containing all the data. This data has to be downloaded from the Google Drive and put at the correct place in the repository to allow a correct running of the code. It contains 2 sub-folders with all the input and should be in `.nii.gz` format : 
    * **raw_labels**: contains 48 files with the labels identifying the artefacts in the corresponding 48 images
    * **raw_images**: contains 48 images of MRI scans 
* **scripts** contains all the scripts necessary to run all the code for predictions : 
    * `cropping.sh` : script that runs the pre-processing of all the data
    * `create_dataset.py`: creates dataset from the data, run it from the scripts format with `python create_dataset.py`
* **set_env.sh**: script that sets the required environment variables
* **unpack_and_organize.py**: run to unpack downloaded dataset and organize it into the data folder

## Setup:
Before running the model, you should follow these steps to make sure you have all the necessary packages and files.
* Create a new conda environment with python version 3.10: `conda create -n dlb python=3.10`
* Activate the recently created environment with : `conde activate dlb` 
* Clone the repository to your computer by running : `git clone https://github.com/Matthieu-Andre/deepl-project.git` 
* Enter our repository : `cd deepl-project` 
* Once this is done run : `git submodule update --init --recursive`
* Then you should download Spinal Cord Toolbox package (sct) to be able to run the pre-processing. To do so, follow this tutorial according to your machine: https://spinalcordtoolbox.com/user_section/installation.html. We used the last version of SCT (6.1)
* Make sure you have the correct version of pytorch installed for your computer. All instructions are to found on this page: https://pytorch.org/get-started/locally/
* Finally go to the folder nnUNet with `cd nnUNet` and run `pip install -e .` to install nnUNet.
You are now all ready to use the model, you just need to load you data according to the folder structure presented above.

## Download data
* Download data from the drive ( link provided on moodle submission ) place the compressed folders at the root of the repo 
* Then run `python unpack_and_organize.py`

## Preprocess data
To process the data it must follow the following structure : 
* in a `raw_images` folder, you should have all your images with the following nomenclature `your_image_0000.nii.gz` 
* in a `raw_labels` folder, you should have all your labels with the following nomenclature `your_image.nii.gz` for the label corresponding to this image `your_image_0000.nii.gz` 
You can then go to scripts folder and from there run the following command : `bash cropping.sh`. This will create 2 new folders in `data` called `labels` and `images` and will contain the processed labels and images respectively following the exact same nomenclature as the raw data. This script crops the images to 35mm box around the spinal cord and down-samples the images with a 0.5 ratio. If you wish to change these parameters, you should modifiy these lines of code : 
* `sct_create_mask -i $image_path -p centerline,$centerline_path -size 35mm -f box -o $mask_path -v '0'` to change the size of the box at `-size`
* `sct_resample -i $cropped_image_path -mm '0.5x0.5x0.5' -o $sampled_image_path -v '0'` and `sct_resample -i $cropped_label_path -mm '0.5x0.5x0.5' -o $sampled_label_path -v '0'` to change the sampling factor under the `-mm` parameter
For more details, we invite you to visit the SCT documentation : https://spinalcordtoolbox.com/user_section/command-line.html#main-tools

## How to run the model from your terminal
* From the root of the repositary run `source set_env.sh` to set the local variables (this needs to be run each time a terminal is opened)
* Then go to the scripts folder and run `python create_dataset.py`
* Then run `nnUNetv2_plan_and_preprocess -d 1 --verify_dataset_integrity` 
* Finally run `nnUNetv2_train 1 3d_fullres all` # to change according to chosen model  
* If you want to run on a specific GPU:    
     `CUDA_VISIBLE_DEVICES=0 nnUNetv2_train 1 3d_fullres all & train on GPU 0`
