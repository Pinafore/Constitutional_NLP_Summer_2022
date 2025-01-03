import json
from pandas import read_csv


with open('read_cases_manualATM_text_list.json', 'r') as f:
    read_cases_manualATM_text_list = json.load(f)

false_neg_id = 7319
print('preprocessed words in false_neg doc 7149', read_cases_manualATM_text_list[false_neg_id])


original_data = read_csv("case_scraping_01_1998_to_07_2022_noNaN.csv")
original_relevant_row = original_data.iloc[7319]
original_relevant_row.to_csv("noNaN_row_7149.csv")

data = read_csv("case_scraping_01_1998_to_07_2022_noNaN_all.csv")
data_relevant_columns = data[['uid', 'dm_family', 'dm2_asylum', 'full_text_x', 'decision_date']]
data_relevant_rows = data_relevant_columns[data_relevant_columns['uid'] == 7319]
data_relevant_rows .to_csv("noNaN_all_uid=7149.csv")




'''
with open('read_cases_manualATM_text_list.json', 'r') as f:
    read_cases_manualATM_text_list = json.load(f)

false_neg_id = 7149
print('preprocessed words in false_neg doc 7149', read_cases_manualATM_text_list[false_neg_id])


original_data = read_csv("case_scraping_01_1998_to_07_2022_noNaN.csv")
original_relevant_row = original_data.iloc[7149]
original_relevant_row.to_csv("noNaN_row_7149.csv")

data = read_csv("case_scraping_01_1998_to_07_2022_noNaN_all.csv")
data_relevant_columns = data[['uid', 'dm_family', 'dm2_asylum', 'full_text_x', 'decision_date']]
data_relevant_rows = data_relevant_columns[data_relevant_columns['uid'] == 7149]
data_relevant_rows .to_csv("noNaN_all_uid=7149.csv")

'''



'''
original_data = read_csv("case_scraping_01_1998_to_07_2022_noNaN.csv")
original_relevant_row = original_data[original_data['decision_date'] == '05. Oktober 1999']
original_relevant_row.to_csv("original_relevant_row_Oct5_1999.csv")


original_data = read_csv("case_scraping_01_1998_to_07_2022_noNaN.csv")
original_relevant_row = original_data.iloc[814]
original_relevant_row.to_csv("original_relevant_row_814.csv")



list_of_cols = data.columns.tolist()
dm_list = []
for col in list_of_cols:
    if col[0:2] == "dm":
        dm_list += [col]
id_dm_list = ["id"] + dm_list
print("id_dm_list:", id_dm_list)



data = read_csv("case_scraping_01_1998_to_07_2022_noNaN_all.csv")
#format: 05. Januar 1998
#date of case 814: 05. Oktober 1999
#814, 6158
data_relevant_columns = data[['uid', 'dm_family', 'dm2_military', 'full_text_x', 'decision_date']]
data_relevant_rows = data_relevant_columns[data_relevant_columns['uid'] == 814]
print('case 814:', str(data_relevant_rows['full_text_x']))
data_relevant_rows.to_csv("false_cases.csv")
#print(data_relevant_rows.head)
#print('relevant_data:', relevant_data)



with open('read_cases_manualATM_text_list.json', 'r') as f:
    read_cases_manualATM_text_list = json.load(f)

false_neg_id = 7149
print('preprocessed words in false_neg doc 813', read_cases_manualATM_text_list[false_neg_id])

false_neg_id = 814
print('preprocessed words in false_neg doc 814 ', read_cases_manualATM_text_list[false_neg_id])

false_neg_id = 815
print('preprocessed words in false_neg doc 815', read_cases_manualATM_text_list[false_neg_id])


#false_pos_id = 6158
#print('preprocessed words in false_pos doc ', read_cases_manualATM_text_list[false_pos_id])
'''
