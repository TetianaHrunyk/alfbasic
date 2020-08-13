"""This code will run statements from a file 
and then write the output to a separate file."""

import psycopg2
import os.path
import time

def run_stmts():
    opened = False
    while not opened:
        try:
            print("Enter the name of the input file: ", end = "")
            in_file_name = input()
            in_file = open(in_file_name, "r")
            opened = True
        except:
            print("Wrong file name")
    opened = False
    exists = False
    while not opened:
        try:
            print("Enter the name of the output file: ", end = "")
            out_file_name = input()
            if os.path.isfile("./"+out_file_name):
                exists = True
            out_file = open(out_file_name, "a+")
            opened = True
        except:
            print("Wrong file name")
    if not exists:
        out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {:<6}| {:<6}| {}\n".format("rows", "tot_costs", "exec_time(ms)", "exec_time_cs", "plan_time", "ncond", "nind", "stmt"))
        out_file.write("----------------------------------------------------------------------------\n")
    
    conn = psycopg2.connect("dbname=alfbasic0 user=postgres password=password")
    cur = conn.cursor()
    ind = 4
    
    gstart = time.time()
    for line in in_file.readlines():
        if len(line) > 3:
            if line[0] == "?":
                cur.execute(line[1:])
                out_file.write(line)
                if "CREATE INDEX" in line:
                    ind += 1
            else:           
                start = time.time()         
#                cur.execute("select count(*) from alfbasic where bstream is not null")
#                r_before = cur.fetchall()
                cur.execute(line)
                json = cur.fetchall()  
                end = time.time()          
                json = json[0][0][0]
#                cur.execute("select count(*) from alfbasic where bstream is not null")
#               r_after = cur.fetchall()
                cond = str(line.count("LIKE"))
                out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {:<6}| {:<6}| {}".format(json["Plan"]["Actual Rows"], json["Plan"]["Total Cost"], json["Plan"]["Actual Total Time"], round((end-start)*1000, 4), json["Planning Time"], cond, ind, line[30:]))
#                out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {:<6}| {:<6}| {}".format(r_after[0][0]-r_before[0][0], json["Plan"]["Total Cost"], json["Plan"]["Actual Total Time"], round((end-start)*100, 4), json["Planning Time"], cond, ind, line[30:]))
        
    gend = time.time()
    in_file.close()
    out_file.close()
    cur.close()
    conn.commit()
    conn.close()
    
    return round((gend-gstart)*1000, 4)
    
    


if __name__ == "__main__":
    
    t = run_stmts()
    
    print("Time(ms) taken for runnig the fuction once: ", t)
    
    
        
    