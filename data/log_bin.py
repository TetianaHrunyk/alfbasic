"""This code will run statements from a file 
and then write the output to a separate file."""

import psycopg2
import os.path
import time
import random
import sys

def run_stmts(low, high, roles_file = None, out_file_name = None, ts_vector = True, commit = True):
    opened = False
    if not roles_file:
        while not opened:
            try:
                print("Enter the name of the roles file: ", end = "")
                roles_file = input()
                roles = open(roles_file, "r")
                opened = True
            except:
                print("Wrong file name")
    else: 
        roles_file = open(roles_file, "r")
        
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
        out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {}\n".format("rows", "tot_costs", "exec_time(ms)", "exec_time_cs", "fsize", "role"))
        out_file.write("----------------------------------------------------------------------------\n")
    
#    conn = psycopg2.connect("dbname=alfbasic0 user=postgres password=password")
    conn = psycopg2.connect("host=alf1.bsystems.cz port=5433 dbname=test user=test password=tetiana.hrunyk")
    cur = conn.cursor()
    f = open('load_files_self_def_functions/file_sizes.txt')
    files = f.readlines()
    gstart = time.time()
    
    for role in roles.readlines():
        for file in files: 
            
            cur.execute("SET ROLE "+role)
            cur.execute("select count(*) from alfbasic where bstream is not null")
            before = cur.fetchall()[0][0]
            arr = get_bin_array(file)
            cn = random.randint(low, high)
            
            start = time.time()
            cur.execute("explain(analyze, format json) select insert_bin_into_alfbasic({}, {})".format(psycopg2.Binary(arr), cn))
            json = cur.fetchall()  
            json = json[0][0][0]
            
            if ts_vector:
                cur.execute("explain(analyze, format json) select add_ts_vectors()")
                json1 = cur.fetchall()  
                json1 = json1[0][0][0]
            
            end = time.time()          
            cur.execute("select count(*) from alfbasic where bstream is not null")
            after = cur.fetchall()[0][0]
            
            
#            out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {:<6}| {}\n".format(after-before, json["Plan"]["Total Cost"], json["Plan"]["Actual Total Time"], round((end-start)*1000, 4), json["Planning Time"], len(arr), role))
            if ts_vector:
                out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {}\n".format(after-before, round((json["Plan"]["Total Cost"]+json1["Plan"]["Total Cost"]), 4), round((json["Plan"]["Actual Total Time"]+json1["Plan"]["Actual Total Time"]), 4), round((end-start)*1000, 4), len(arr), role))      
            else:
                out_file.write("{:<8}| {:<12}| {:<15}| {:<12}| {:<12}| {}\n".format(after-before, round((json["Plan"]["Total Cost"]), 4), round((json["Plan"]["Actual Total Time"], 4), round((end-start)*1000, 4), len(arr), role))       
            if commit:   
                conn.commit()
            else:
                conn.rollback()
    gend = time.time()
    roles.close()
    out_file.close()
    cur.close()
    conn.commit()
    conn.close()
    
    return round((gend-gstart)*1000, 4)
    
def get_bin_array(path):
    f = open(path[:-1], mode = "rb")
    stream = f.read()
    f.close()
    return stream

def main():
    args = [arg for arg in sys.argv[1:]]
    run_stmts(*args)


if __name__ == "__main__":
    main()
    
    
#    t = run_stmts() 
#    print("Time(ms) taken for runnig the fuction once: ", t)
    
    
        
    