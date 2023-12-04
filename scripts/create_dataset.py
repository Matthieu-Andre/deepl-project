import os
import shutil
import json


def create_nnunet_dataset(
    data_folder: str, dataset_folder: str, train_test_split: float
):
    if not os.path.exists(data_folder):
        raise ValueError(
            'Data folder does not exist, please name your data folder as "data"'
        )
    train_folder = os.path.join(dataset_folder, "imagesTr")
    test_folder = os.path.join(dataset_folder, "imagesTs")
    labels_train_folder = os.path.join(dataset_folder, "labelsTr")
    labels_test_folder = os.path.join(dataset_folder, "labelsTs")

    # Create directories
    os.makedirs(train_folder, exist_ok=True)
    os.makedirs(test_folder, exist_ok=True)
    os.makedirs(labels_train_folder, exist_ok=True)
    os.makedirs(labels_test_folder, exist_ok=True)

    images_folder = os.path.join(data_folder, "images")
    labels_folder = os.path.join(data_folder, "labels")

    # List files
    images = sorted(os.listdir(images_folder))
    labels = sorted(os.listdir(labels_folder))

    split_index = int(len(images) * train_test_split)

    # Copy data
    for file_name in images[:split_index]:
        if file_name.endswith(".nii.gz"):
            shutil.copy(os.path.join(images_folder, file_name), train_folder)

    for file_name in images[split_index:]:
        if file_name.endswith(".nii.gz"):
            shutil.copy(os.path.join(images_folder, file_name), test_folder)

    # Copy label files
    for label_name in labels[:split_index]:
        if label_name.endswith(".nii.gz"):
            shutil.copy(os.path.join(labels_folder, label_name), labels_train_folder)

    for label_name in labels[split_index:]:
        if label_name.endswith(".nii.gz"):
            shutil.copy(os.path.join(labels_folder, label_name), labels_test_folder)

    # Create dataset.json
    dataset_json = {
        "name": "spine-mri",
        "description": "spinal cord mri",
        "description": "spinal cord mri",
        "file_ending": ".nii.gz",
        "channel_names": {
            "0": "T2",
        },
        "modality": {
            "0": "mri",
        },
        "labels": {
            "background": 0,
            "bending artefact": 1,
        },
        "numTraining": len(os.listdir(train_folder)),
    }

    with open(os.path.join(dataset_folder, "dataset.json"), "w") as json_file:
        json.dump(dataset_json, json_file, indent=4)


# Example usage
data_folder = "./../data"
dataset_folder = "./../nnUNet_raw/Dataset001_spine-mri"
train_test_split = 0.8
create_nnunet_dataset(data_folder, dataset_folder, train_test_split)
