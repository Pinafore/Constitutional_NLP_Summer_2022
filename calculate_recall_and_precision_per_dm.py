import csv
from pandas import *
import pickle
import json
import argparse
from statistics import stdev, median_high


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


#print("data_compact:", data_compact)

def recall_and_precision(dm, topic_to_domain_dict, data_compact, topics_prob_per_doc_all):
#Function to calculate recall and precision for each dm variable
    print('dm:', dm)
    topics_corresponding_to_dm = []
    for k, v in topic_to_domain_dict.items():
        #print('v', v)
        if v == dm:
            topics_corresponding_to_dm  += [int(k)]
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
        #print('row[dm]:', row[dm])
        if row[dm] == 1:
            if len(intersection) > 0:
                true_pos += 1
            else:
                false_neg += 1
        elif row[dm] == 0:
            if len(intersection) > 0:
                false_pos += 1

    recall = true_pos/(true_pos+false_neg+0.000001)
    precision = true_pos/(true_pos+false_pos+0.000001)
    #print('true_pos:', true_pos)
    #print('false_neg:', false_neg)
    #print('false_pos:', false_pos)
    print('recall:', recall)
    print('precision:', precision)

    return dm, recall, precision




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


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Calculate recall and precision per domain")
    parser.add_argument('--num_topics', type=int, default=50)
    parser.add_argument('--map', type=str, default="automatic")

    flags = parser.parse_args()


    if flags.map == "automatic":
        with open('automatic_topic_to_domain_map_num_topics=' + str(flags.num_topics) + '.json', 'r') as f:
            topic_to_domain_dict = json.load(f)
        print('topic_to_domain_dict:', topic_to_domain_dict)
    elif flags.map == "manual" and flags.num_topics == 50:
        #Manual Map (num_topics = 50)
        topic_to_domain_dict = {0: "dm2_european", 2: "dm_speech", 4: "dm2_reinstatement", 7: "dm_levies",
                                9: "dm_professions",
                                14: "dm2_parliament", 15: "dm_child", 18: "dm_labour", 19: "dm_healthinsurance",
                                20: "dm_welfare",
                                23: "dm2_asylum", 24: "dm_family", 25: "dm_tax", 26: "dm2_international",
                                27: "dm_freedomgeneral",
                                28: "dm_socialsecurity", 30: "dm_property", 31: "dm2_european", 32: "dm_healthinsurance",
                                33: "dm2_extradition", 37: "dm2_parliament", 40: "dm2_pretrial", 41: "dm_labour",
                                42: "dm2_prosecution",
                                45: "dm2_publicservice", 46: "dm2_detention", 47: "dm_labour", 48: "dm2_detention",
                                49: "dm_property"}



    # Create a list of list for the top 3 topics of each document
    with open('WardNJU_topics_per_doc_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        topics_prob_per_doc_all = pickle.load(f)
 
    data_compact = read_csv("id_and_domains_Aug01.csv")

    dm_list = []
    recall_list = []
    precision_list = []

    for dm in set(topic_to_domain_dict.values()):
        dm, recall, precision = recall_and_precision(dm, topic_to_domain_dict, data_compact, topics_prob_per_doc_all)
        dm_list.append(dm)
        recall_list.append(recall)
        precision_list.append(precision)

    #print('dm_list:', dm_list)
    #rint('recall_list:', recall_list)
    #print('precision_list:', precision_list)

    recall_max = max(recall_list)
    print('recall_max:', recall_max)
    recall_max_idx = recall_list.index(recall_max)
    dm_recall_max = dm_list[recall_max_idx]
    print('dm_recall_max:', dm_recall_max)

    precision_max = max(precision_list)
    print('precision_max:', precision_max)
    precision_max_idx = precision_list.index(precision_max)
    dm_precision_max = dm_list[precision_max_idx]
    print('dm_precision_max:', dm_precision_max)


    recall_upper_quartile = np.percentile(recall_list, 75, method='closest_observation')
    print('recall_upper_quartile:', recall_upper_quartile)
    recall_upper_quartile_idx = recall_list.index(recall_upper_quartile)
    dm_recall_upper_quartile = dm_list[recall_upper_quartile_idx]
    print('dm_recall_upper_quartile:', dm_recall_upper_quartile)

    precision_upper_quartile = np.percentile(precision_list, 75, method='closest_observation')
    print('precision_upper_quartile:', precision_upper_quartile)
    precision_upper_quartile_idx = precision_list.index(precision_upper_quartile)
    dm_precision_upper_quartile = dm_list[precision_upper_quartile_idx]
    print('dm_precision_upper_quartile:', dm_precision_upper_quartile)


    recall_med = np.percentile(recall_list, 50, method='closest_observation')
    print('recall_med:', recall_med)
    recall_med_idx = recall_list.index(recall_med)
    dm_recall_med = dm_list[recall_med_idx]
    print('dm_recall_med:', dm_recall_med)

    precision_med = np.percentile(precision_list, 50, method='closest_observation')
    print('precision_med:', precision_med)
    precision_med_idx = precision_list.index(precision_med)
    dm_precision_med = dm_list[precision_med_idx]
    print('dm_precision_med:', dm_precision_med)


    recall_lower_quartile = np.percentile(recall_list, 25, method='closest_observation')
    print('recall_lower_quartile:', recall_lower_quartile)
    recall_lower_quartile_idx = recall_list.index(recall_lower_quartile)
    dm_recall_lower_quartile = dm_list[recall_lower_quartile_idx]
    print('dm_recall_lower_quartile:', dm_recall_lower_quartile)

    precision_lower_quartile = np.percentile(precision_list, 25, method='closest_observation')
    print('precision_lower_quartile:', precision_lower_quartile)
    precision_lower_quartile_idx = precision_list.index(precision_lower_quartile)
    dm_precision_lower_quartile = dm_list[precision_lower_quartile_idx]
    print('dm_precision_lower_quartile:', dm_precision_lower_quartile)


    recall_min = min(recall_list)
    print('recall_min:', recall_min)
    recall_min_idx = recall_list.index(recall_min)
    dm_recall_min = dm_list[recall_min_idx]
    print('dm_recall_min:', dm_recall_min)

    precision_min = min(precision_list)
    print('precision_min:', precision_min)
    precision_min_idx = precision_list.index(precision_min)
    dm_precision_min = dm_list[precision_min_idx]
    print('dm_precision_min:', dm_precision_min)



    #with open('recall_and_precision_' + str(flags.map) + '_num_topics=' + str(num_topics) + '.json', 'w') as f:
    #   json.dump(automatic_topic_to_domain_map, f)

    #with open('recall_and_precision_' + str(flags.map) + '_num_topics=' + str(num_topics) + '.json', 'r') as f:
    #    automatic_topic_to_domain_map = json.load(f)
