image_folder="../data/restore/raw_images/"
label_folder="../data/restore/raw_labels/"

mkdir ../data/restore/images
mkdir ../data/restore/labels

processed_folder_image="../data/restore/images/"
processed_folder_label="../data/restore/labels/"

for image in `ls $image_folder`; do
    
    image_path="${image_folder}${image}"
    label_path="${label_folder}${image%_0000*}.nii.gz"

    #centerline_path="${processed_folder_image}centerline_${image}"
    centerline_path="${processed_folder_image}centerline_${image}"
    centerline_path_csv="${processed_folder_image}centerline_${image%_0000*}_0000.csv"
    echo $centerline_path_csv
    mask_path="${processed_folder_label}mask_${image}"

    cropped_image_path="${processed_folder_image}image_cropped_${image}"
    sampled_image_path="${processed_folder_image}${image}"

    cropped_label_path="${processed_folder_label}label_cropped_${image%_0000*}.nii.gz"
    sampled_label_path="${processed_folder_label}${image%_0000*}.nii.gz"

    #sct_image -i $image_path
    #sct_convert -i $image_path -o $centerline_path -v '2'
    sct_get_centerline -i $image_path -c 't2' -o $centerline_path -v '0'
    sct_create_mask -i $image_path -p centerline,$centerline_path -size 35mm -f box -o $mask_path -v '0'
    sct_crop_image -i $image_path -m $mask_path -o $cropped_image_path -v '0'
    sct_crop_image -i $label_path -m $mask_path -o $cropped_label_path -v '0'
    sct_resample -i $cropped_image_path -mm '0.5x0.5x0.5' -o $sampled_image_path -v '0'
    sct_resample -i $cropped_label_path -mm '0.5x0.5x0.5' -o $sampled_label_path -v '0'

    rm $mask_path
    rm $cropped_image_path
    rm $centerline_path
    rm $centerline_path_csv
    rm $cropped_label_path
    rm $centerline_path
done
