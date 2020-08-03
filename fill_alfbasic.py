"""This code connect to the database, retrieves the data from the main tables,
creates a randomized queries from the retrived data. The data are then inserted
into the dependent database.

This schema of creating the randomized data was selected to insure that new data
can be inserted into the main tables and then it can be added to the dependent table.
This schema also insures referential integrity.
"""
import psycopg2
import random

def fetch_values(table, column):
    cur = conn.cursor()
    q = "SELECT " + column + " FROM " + table
    cur.execute(q)
    rows = cur.fetchall()
    cur.close()
    return rows

def insert_rand_data_into_alf(n):
    """works only for this specific table"""
    cur = conn.cursor()
    stmt = "INSERT INTO alfbasic (tenant, casetype, acta, stage, udim1, udim2, udim3) VALUES "
    for _ in range(n):
        q = []
        q.append(random.choice(tenants)[0])
        q.append(random.choice(case_types)[0])
        q.append(random.choice(acts)[0])
        q.append(random.choice(stages)[0])
        q.append(random.choice(udim1)[0])
        q.append(random.choice(udim2)[0])
        q.append(random.choice(udim3)[0])
        to_insert = stmt + str(tuple(q)) + ";"
        cur.execute(to_insert)
    conn.commit()
    cur.close()



if __name__ == "__main__":
    conn = psycopg2.connect("dbname=alfbasic0 user=postgres password=password")
    
    stages = fetch_values("stages", "stage")
    tenants = fetch_values("tenants", "tenant")
    acts = fetch_values("acty", "acta")
    case_types = fetch_values("case_types", "casetype")
    udim1 = fetch_values("udim1", "dname")
    udim2 = fetch_values("udim2", "dname")
    udim3 = fetch_values("udim3", "dname")
    
    insert_rand_data_into_alf(30000)
    
    conn.close()