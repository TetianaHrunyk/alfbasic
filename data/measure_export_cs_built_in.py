#______________NOTE___________________
#In order to use lo.export from psycopg2 library, change lo_compat_privileges to on in postgresql.conf.

import psycopg2
import os.path
import time

def export_files():
    opened = False
    while not opened:
        try:
            print("Enter the name of the base file: ", end = "")
            file_name = input()
            file = open(file_name, "r")
            opened = True
        except:
            print("Wrong file name")
    out_file = open(file_name[:-4]+"_output"+".csv", "a+")
    if not os.path.isfile(file_name[:-4]+"_output"+".csv"):
        out_file.write("{:<8}| {:<15}| {:<6}| {:<6}| {}\n".format("rows", "exec_time(ms)", "ncond", "nind", "stmt"))
        out_file.write("----------------------------------------------------------------------------\n")
    
    conn = psycopg2.connect("dbname=alfbasic0 user=postgres password=password")
    cur = conn.cursor()
    ind = 0
    
    for line in file.readlines():
        if len(line) > 3:
            if line[0] == "?":
                cur.execute(line[1:])
                out_file.write(line)
                if "CREATE INDEX" in line:
                    ind += 1
            else:
#               MEASURMENT TIME STARTS HERE. 
#We are measuring the time for getting the oids list and then exporting all the files with given oids.
                start = time.time()
                cur.execute(line)
                oids = cur.fetchall()
                i = 1
                for oid in oids:
                    lo = conn.lobject(oid[0])  
#CHANGE THE FOLLOWING LINE LATER SO AS NOT TO PRODUCE LOTS OF JUNK FILES
                    lo.export('/home/tania/Code/alf/data/exported_files/file'+str(i)+".docx")
                    i += 1
                end = time.time()
                cond = str(line.count("LIKE"))
                out_file.write("{:<8}| {:<15}| {:<6}| {:<6}| {}".format(len(oids), round((end-start)*100, 4), cond, ind, line))
        
    file.close()
    out_file.close()
    cur.close()
    conn.close()
    
if __name__ == "__main__":
    export_files()