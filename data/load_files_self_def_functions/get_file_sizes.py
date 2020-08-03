def get_file_sizes(path):
    from pathlib import Path
    from os import listdir
    from os.path import isfile, join
    files = [f for f in listdir(path) if isfile(join(path, f))]
    f = open('file_sizes.txt', 'w+')
    for file in files:
        size = Path(path+file).stat().st_size
        f.write(path+file+', '+str(size)+'\n')
    f.close()
    
if __name__ == "__main__":
    get_file_sizes("/home/tania/Code/alf/data/exported_files/original_files/")
        
