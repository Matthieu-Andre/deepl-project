import os 

# list all zip files in the current directory
zip_files = [f for f in os.listdir('.') if f.endswith('.zip') and f.startswith('data')]
unzipped = [ f.replace('.zip', '') for f in zip_files]

# unzip each file in the current directory into its own folder
for zip_filename in zip_files:
    dir_name = os.path.splitext(zip_filename)[0]
    os.mkdir(dir_name)
    os.system('unzip {0} -d {1}'.format(zip_filename, dir_name))


# analyze the structure of each unzipped folder
for dir_name in unzipped:
    # walk the directory tree
    for root, dirs, files in os.walk(dir_name):
        # print(root)
        # remove first layer of root
        root = root.replace(dir_name, '')
        if root.startswith('/'):
            root = root[1:]
            print('    ', root)
            os.makedirs(root, exist_ok=True)
            # print('    ', files)
            for f in files:
                os.rename(os.path.join(dir_name, root, f), os.path.join(root, f))



# delete unzipped folders
for dir_name in unzipped:
    os.system('rm -r {0}'.format(dir_name))