ex = []
def read(path):
    import re
    def chunkstring(string, length):
        return [string[0+i:length+i] for i in range(0, len(string), length)]
    import pandas as pd    
    xls = pd.ExcelFile(path)
    
    excel_csv_tot = ""
    for sheet in xls.sheet_names:
        excel = pd.read_excel(path, separator = " ", sheet_name=sheet)
        excel= excel.astype(object)
        excel.dropna(how="all", axis = 1, inplace=True)
        excel.dropna(how="all", axis = 0, inplace=True)
        ex.append(excel)
        excel_csv = excel.to_csv(index=False, line_terminator=" ")
        excel_csv=excel_csv.lower()
#        excel_csv=excel_csv.replace('"', " ")
        excel_csv = re.sub(r",+", " ", excel_csv)
        excel_csv = re.sub(r"\ +", " ", excel_csv)
        excel_csv=excel_csv.strip()
        excel_csv_tot += excel_csv

   
    return excel_csv_tot

read('/home/tania/Code/alf/data/exported_files/original_files/5-year-financial-plan.xlsx')
