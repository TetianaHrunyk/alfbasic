# log_bin.py:
#  low, high, roles_file = None, out_file_name = None, ts_vector = True, commit = True

#text_search_log.py:
#  in_file_name = None, out_file_name = None

python3 log_bin.py 1 1 'V4/roles.txt' 'V4/server_data/bin_out.csv' False False
python3 log_bin.py 1 1 'V4/roles.txt' 'V4/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V4/merged.txt' 'V4/server_data/merge_out.csv'

python3 log_bin.py 1 1 'V3/roles.txt' 'V3/server_data/bin_out.csv' False False
python3 log_bin.py 1 1 'V3/roles.txt' 'V3/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V3/merged.txt' 'V3/server_data/merge_out.csv'


python3 text_search_log.py 'V0/merged.txt' 'V0/server_data/merge_out0.csv'


python3 log_bin.py 40 60 'V2/roles.txt' 'V2/server_data/bin_out.csv' False False

python3 log_bin.py 80 100 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out1.csv'

python3 log_bin.py 60 79 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out2.csv'

python3 log_bin.py 40 59 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out3.csv'

python3 log_bin.py 20 39 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out4.csv'

python3 log_bin.py 10 19 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out5.csv'

python3 log_bin.py 1 5 'V2/roles.txt' 'V2/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V2/merged.txt' 'V2/server_data/merge_out6.csv'

python3 text_search_log.py 'V2/merged_ex1.txt' 'V2/server_data/merge_ex1_out.csv'
python3 text_search_log.py 'V2/merged_ex2.txt' 'V2/server_data/merge_ex2_out.csv'
python3 text_search_log.py 'V2/merged_ex3.txt' 'V2/server_data/merge_ex3_out.csv'
python3 text_search_log.py 'V2/merged_ex4.txt' 'V2/server_data/merge_ex4_out.csv'
python3 text_search_log.py 'V2/merged_ex5.txt' 'V2/server_data/merge_ex5_out.csv'

python3 log_bin.py 40 60 'V1/roles.txt' 'V1/server_data/bin_out.csv' False False

python3 log_bin.py 80 100 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out1.csv'

python3 log_bin.py 60 79 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out2.csv'

python3 log_bin.py 40 59 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out3.csv'

python3 log_bin.py 20 39 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out4.csv'

python3 log_bin.py 10 19 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out5.csv'

python3 log_bin.py 1 5 'V1/roles.txt' 'V1/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V1/merged.txt' 'V1/server_data/merge_out6.csv'

python3 text_search_log.py 'V1/merged_ex1.txt' 'V1/server_data/merge_ex1_out.csv'
python3 text_search_log.py 'V1/merged_ex2.txt' 'V1/server_data/merge_ex2_out.csv'
python3 text_search_log.py 'V1/merged_ex3.txt' 'V1/server_data/merge_ex3_out.csv'
python3 text_search_log.py 'V1/merged_ex4.txt' 'V1/server_data/merge_ex4_out.csv'


python3 log_bin.py 20000 21000 'V0/roles.txt' 'V0/server_data/bin_out.csv' False False
python3 log_bin.py 20000 21000 'V0/roles.txt' 'V0/server_data/bin_ts_out.csv' 
python3 text_search_log.py 'V0/merged.txt' 'V0/server_data/merge_out1.csv'