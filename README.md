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
* Create a new environment:
* after cloning ( or if nnUNet submodule is empty ) run : `git submodule update --init --recursive`


# HOW TO RUN
* Run `source set_env.sh` to set the local variables ( needs to be run each time a terminal is opened )