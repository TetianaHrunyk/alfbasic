def read_excel_file(path):
    import pandas as pd
    import re
    import math
    import psycopg2
    def chunkstring(string, length):
        return [string[0+i:length+i] for i in range(0, len(string), length)]
    
    limit = 1e+9
    xls = pd.ExcelFile(path)
    
    excel_csv_tot = ""
    for sheet in xls.sheet_names:
        excel = pd.read_excel(path, separator = " ", sheet_name=sheet)
        excel.dropna(how="all", axis = 1, inplace=True)
        excel.dropna(how="all", axis = 0, inplace=True)
        excel_csv = excel.to_csv(index=False, line_terminator=" ")
        excel_csv=excel_csv.lower()
        excel_csv=excel_csv.replace('"', " ")
        excel_csv = re.sub(r",+", " ", excel_csv)
        excel_csv = re.sub(r"\ +", " ", excel_csv)
        excel_csv=excel_csv.strip()
        excel_csv_tot += excel_csv
    
    size = len(excel_csv_tot.encode("utf8"))
    
    if size <= limit:
        return [excel_csv]
    else:
#NOTE: the flaw of this function is that it will break every 10e+9th word 
#unless a blank space will occasionally occur at the breaking point
        chunks = size//limit + 1
        chunk_size = math.ceil(len(excel_csv_tot)/chunks)
        return chunkstring(excel_csv_tot, chunk_size)


if __name__ == "__main__":
    for c in read_excel_file(50090): 
        print(c)
        print()

