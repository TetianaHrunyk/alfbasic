opened = False
while not opened:
    try:
        print("Enter the name of the base file: ", end = "")
        file_name = input()
        file = open(file_name, "r")
        opened = True
    except:
        print("Wrong file name")

modified = open(file_name[:-4]+"_self_def_exp"+file_name[-4:], "w+")


for line in file.readlines():
    if "SELECT * FROM alfbasic" in line:
        new_line = line.replace('*', 'CaseNumber')
        if "WHERE" in line:
            new_line = new_line[30:-2]+ " AND bstream is not Null;\n"
        else:
            new_line = new_line[30:-2]+ " WHERE bstream is not Null;\n"
        modified.write(new_line)
    else:
        modified.write(line)
        
file.close()
modified.close()