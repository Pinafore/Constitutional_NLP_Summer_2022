import csv
from pandas import *
import pickle
topic_to_domain_dict = {0:"dm2_european", 2:"dm_speech", 4:"dm2_reinstatement", 7:"dm_levies", 9:"dm_professions",
                        14:"dm2_parliament", 15:"dm_child", 18:"dm_labour", 19:"dm_healthinsurance", 20:"dm_welfare",
                        23:"dm2_asylum", 24:"dm_family", 25:"dm_tax", 26:"dm2_international", 27:"dm_freedomgeneral",
                        28:"dm_socialsecurity", 30:"dm_property", 31:"dm2_european", 32:"dm_healthinsurance",
                        33:"dm2_extradition", 37:"dm2_parliament", 40:"dm2_pretrial", 41:"dm_labour", 42:"dm2_prosecution",
                        45:"dm2_publicservice", 46:"dm2_detention", 47:"dm_labour", 48:"dm2_detention", 49:"dm_property"}


num_topics = 50
#Create a list of list for the top 3 topics of each document
with open('WardNJU_topics_per_doc_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    topics_prob_per_doc_all = pickle.load(f)

#Create a topics_prob_per_doc dictionary where keys are bverfg_id_forward


# open the file in read mode


'''
# Construct a compact csv with only id (0-8111) and domains
data = read_csv("case_scraping_01_1998_to_07_2022_noNaN_all.csv")
list_of_cols = data.columns.tolist()
dm_list = []
for col in list_of_cols:
    if col[0:2] == "dm":
        dm_list += [col]
id_dm_list = ["id"] + dm_list
print("id_dm_list:", id_dm_list)

data_compact = data[id_dm_list]
print(data_compact.head)
data_compact.to_csv("id_and_domains_Aug01.csv")
'''



data_compact = read_csv("id_and_domains_Aug01.csv")
#print("data_compact:", data_compact)

def recall_and_precision(dm):
#Function to calculate recall and precision for each dm variable
    print('dm:', dm)
    topics_corresponding_to_dm = []
    for k, v in topic_to_domain_dict.items():
        #print('v', v)
        if v == dm:
            topics_corresponding_to_dm  += [k]
    #print('topics_corresponding_to_dm :', topics_corresponding_to_dm )


    df = data_compact[['id'] + [dm]]
    #print('df:', df)

    true_pos = 0
    false_neg = 0
    false_pos = 0
    for index, row in df.iterrows():
        id = row['id']
        ATM_topics = [int(topic) for topic in topics_prob_per_doc_all[id].keys()]
        #print('ATM_topics:', ATM_topics)
        intersection = list(set(topics_corresponding_to_dm).intersection(set(ATM_topics)))
        #print('intersection:', intersection)

        if row[dm] == 1:
            if len(intersection) > 0:
                true_pos += 1
            else:
                false_neg += 1
        elif row[dm] == 0:
            if len(intersection) > 0:
                false_pos += 1

    recall = true_pos/(true_pos+false_neg)
    precision = true_pos/(true_pos+false_pos)
    #print('true_pos:', true_pos)
    #print('false_neg:', false_neg)
    #print('false_pos:', false_pos)
    print('recall:', recall)
    print('precision:', precision)

    return recall, precision




for dm in set(topic_to_domain_dict.values()):
    recall_and_precision(dm)


#true_pos = cases with dm_env = 1 and topic = 10 (because topic 10 -> dm_env)
#false_neg = cases with dm_env = 1 but topics = [3,4,5], ...
#false_pos = cases where topic 10 is in the topic list, but dm_env = 0 (must filter out cases where dm_env = -1, i.e. NaN)

#Procedure to calculate the recall of each dm, e.g.


#Find the indices of all documents where dm_environmental = 1

#For each doc, Check if any of the topic(s) mapped to this dm variable are present in the list of top 3 topics associated to that doc
#If yes, add one to true_pos
#If no, add one to false_neg



#recall = true_pos / (true_pos + false_neg)

#Procedure to calculate the precision of each topics = 10 -> dm_environmental

#precision = true_pos / (true_pos + false_pos)
