opened = False
while not opened:
    try:
        print("Enter the name of the base file: ", end = "")
        file_name = input()
        file = open(file_name, "r")
        opened = True
    except:
        print("Wrong file name")

modified = open(file_name[:-4]+"_mod"+file_name[-4:], "w+")


for line in file.readlines():
    if "SELECT * FROM alfbasic" in line:
        new_line = "SELECT file_oid FROM files INNER JOIN alfbasic ON (files.casenumber = alfbasic.casenumber)"+ line[52:]
        modified.write(new_line)
    else:
        modified.write(line)
        
file.close()
modified.close()