# deepl-project


# Structure ( feel free to change )
* **sergio_code**: the 3 scripts that Sergio gave us
* **nnUNet**: the cloned nnunet repo ( should not be pushed, added to gitignore)
* **data**: folder containing all the data should all be in .gz
    * **labels**: labeled data of the patients
    * **images**: mri scans 
* **scripts** contains scripts
    * **create_dataset.py**: creates dataset from the data, run it from the scripts format with `python create_dataset.py`
* **set_env.sh**: sets the environment variables needed


# Setup:
* Create a new environment with python version 3.10: conda create -n dlb python=3.10
* after cloning ( or if nnUNet submodule is empty ) run : `git submodule update --init --recursive`
* download sct: https://spinalcordtoolbox.com/user_section/installation/linux.html
    * bash install_sct-6.1_linux.sh
* install the correct version of pytorch for your computer: https://pytorch.org/get-started/locally/
* pip install nnUNetv2

# Preprocess data
* go to folder scripts
* run bash cropping.sh

# HOW TO RUN (everything in terminal)
* Run `source set_env.sh` to set the local variables ( needs to be run each time a terminal is opened )
* Run `python create_dataset.py`
* Run nnUNetv2_plan_and_preprocess -d 1 --verify_dataset_integrity
* Run nnUNetv2_train 1 3d_fullres all -num_gpus 3 (of course, change to the number of GPU you have)