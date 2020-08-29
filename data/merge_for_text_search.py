def merge(mod):
    opened = False
    while not opened:
        try:
            print("Enter the name of the file with conditions: ", end = "")
            in_file_name = input()
            cond = open(in_file_name, "r")
            opened = True
        except:
            print("Wrong file name")
    opened = False
    print()
    while not opened:
        try:
            print("Enter the name of the file with search queries: ", end = "")
            file_name = input()
            q = open(file_name, "r")
            opened = True
        except:
            print("Wrong file name")
    opened = False
    print()
    while not opened:
        try:
            print("Enter the name of the output file: ", end = "")
            out_file_name = input()
            out = open(out_file_name, "a+")
            opened = True
        except:
            print("Wrong file name")
    print()
    counter = 0
    queries = q.readlines()
    for c in cond:
        if c[0] == "?" or len(c) < 3:
            if "index" not in c:
                out.write(c)
            continue
        for query in queries:
            if query[0]=='?':     
                continue
            if len(query) > 3:
                if counter % mod == 0:
                    line = c[:-2] + ' intersect ' + query[30:]
                    line = line.replace('*', "CaseNumber")
                    if 'alfbasic and' in line:
                        line = line.replace('alfbasic and', "alfbasic where ")
                    out.write(line)
                counter += 1
    out.close()
    q.close()
    cond.close()
    
            
            
if __name__ == "__main__":
    merge(1)
    
    
    
    
    
    
    
    
    
    
            
    