image_folder="../data/images/"
label_folder="../data/labels/"
processed_folder="../data/processed/"

for image in `ls $image_folder`; do
    
    image_path="${image_folder}${image}"
    label_path="${label_folder}${image%_0000*}.nii.gz"

    centerline_path="${processed_folder}${image%_0000*}_centerline.nii.gz"
    mask_path="${processed_folder}${image%_0000*}_mask.nii.gz"

    cropped_image_path="${processed_folder}${image%_0000*}_i_p.nii.gz"
    sampled_image_path="${processed_folder}${image%_0000*}_i_p_s.nii.gz"

    cropped_label_path="${processed_folder}${image%_0000*}_l_p.nii.gz"
    sampled_label_path="${processed_folder}${image%_0000*}_l_p_s.nii.gz"

    sct_get_centerline -i $image_path -c 't2' -o $centerline_path -v '0'
    sct_create_mask -i $image_path -p centerline,$centerline_path -size 35mm -f box -o $mask_path -v '0'
    sct_crop_image -i $image_path -m $mask_path -o $cropped_image_path -v '0'
    sct_crop_image -i $label_path -m $mask_path -o $cropped_label_path -v '0'
    sct_resample -i $cropped_image_path -mm '0.5x0.5x0.5' -o $sampled_image_path -v '0'
    sct_resample -i $cropped_label_path -mm '0.5x0.5x0.5' -o $sampled_label_path -v '0'

    rm $mask_path
    rm $cropped_image_path
    rm $cropped_label_path
    rm $centerline_path
done
