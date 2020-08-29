"""This code will run statements from a file 
and then write the output to a separate file."""

import psycopg2
import os.path
import time
import sys

def run_stmts(in_file_name = None, out_file_name = None):
    opened = False
    if not in_file_name:
        while not opened:
            try:
                print("Enter the name of the input file: ", end = "")
                in_file_name = input()
                in_file = open(in_file_name, "r")
                opened = True
            except:
                print("Wrong file name")
    else: 
        in_file = open(in_file_name, "r")
    exists = False
    if not out_file_name:
        opened = False
        
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
    else:
        if os.path.isfile("./"+out_file_name):
            exists = True
        out_file = open(out_file_name, "a+")
    
    if not exists:
        out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<6}| {:<12}| {:10}\n".format("rows", "tot_costs", "exec_time(ms)", "exec_time_cs", "ncond", "role", "av_data"))
        out_file.write("----------------------------------------------------------------------------\n")
    
    conn = psycopg2.connect("dbname=alfbasic0 user=postgres password=password")
#    conn = psycopg2.connect("host=alf1.bsystems.cz port=5433 dbname=test user=test password=tetiana.hrunyk")
    cur = conn.cursor()

    
    gstart = time.time()
    for line in in_file.readlines():
        if len(line) > 3:
            if line[0] == "?":
                cur.execute(line[1:])
                out_file.write(line)
            else:           
                cur.execute('SELECT current_user')
                user = cur.fetchone()[0]
                
                cur.execute("select sum(asize) from alfbasic where bstream is not null")
                data = cur.fetchone()[0]
                
                start = time.time()
                cur.execute(line)
                json = cur.fetchall()  
                end = time.time()          
                json = json[0][0][0]
                cond = str(line.count("LIKE"))
                
                out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<6}| {:<12}| {:10}\n".format(json["Plan"]["Actual Rows"], json["Plan"]["Total Cost"], json["Plan"]["Actual Total Time"], round((end-start)*100, 4), cond, user, data))
    
    gend = time.time()
    in_file.close()
    out_file.close()
    cur.close()
    conn.commit()
    conn.close()
    
    return round((gend-gstart)*1000, 4)
    
def main():
    args = [arg for arg in sys.argv[1:]]
    run_stmts(*args)


if __name__ == "__main__":
    
    main()
    #t = run_stmts()
    #print("Time(ms) taken for runnig the fuction once: ", t)
    
    
        
    
