import pandas as pd
import json
import re
import numpy as np
import pickle

num_topics = 200

df = pd.read_csv('bverfg230107_with_break_noNaN.csv')
columns = list(df.columns)
rf_columns = []
for col in columns:
    if col[:3] == 'ref':
        #print('col:', col)
        rf_columns.append(col)

#print('rf_columns:', rf_columns)
#print('len(rf_columns):', len(rf_columns)) # 50


with open('WardNJU_authors_per_doc_topN=8_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    authors_prob_per_doc_all = pickle.load(f)  #format: {0: {'limbach': 0.49, 'winter': 0.37, 'kruis': 0.14}, 1: {'kuehling': 0.4, 'jaeger': 0.35, 'steiner': 0.26}, ...}


print('authors_prob_per_doc_all:', authors_prob_per_doc_all)
#authors_prob_per_doc_all.replace('brossss', 'bross')
top2authors_per_doc = {}
for k, v in authors_prob_per_doc_all.items():
    #print(k)
    if len(list(v.keys())) > 0:
        top2authors_per_doc[k] = list(v.keys())[:2]
    #else:
    #    top2authors_per_doc[k] = np.nan
print('top2authors_per_doc:', top2authors_per_doc)

for key, value in top2authors_per_doc.items():
    top2authors_per_doc[key] = [item.replace('brossss', 'bross') for item in value]

top2authors_per_doc_lol = list(top2authors_per_doc.values())


top2authors_per_doc_lol = [element for element in top2authors_per_doc_lol if str(element) != "nan"]
print('top2authors_per_doc_lol:', top2authors_per_doc_lol)

flat_top2authors_per_doc_lol = [item for sublist in top2authors_per_doc_lol for item in sublist]
unique_authors = np.unique(flat_top2authors_per_doc_lol)
#unique_authors = np.unique(list(top2authors_per_doc.values()))
print('unique_authors:', unique_authors)
#print('len(unique_authors):', len(unique_authors)) #53

#Construct a map from referee to author variable (e.g. ref_kuehling -> kuehling)
ref_to_author_dict = {}
for author in unique_authors:
    for ref in rf_columns:
        if (author == ref[4:]) | (author == ref[5:]):
            print('author:', author)
            print('ref:', ref)
            ref_to_author_dict[ref] = author
#print('ref_to_author_dict:', ref_to_author_dict)
#print('len(ref_to_author_dict):', len(ref_to_author_dict)) #50



'''
#This portion constructs a df (pkl file) that has 2 columns: uid and ground-truth referees (2 referees per case)
df_with_2_ref = df[((df["sumref"] == 2) & (df["sumref2"] == 0)) | ((df["sumref"] == 1) & (df["sumref2"] == 1)) | ((df["sumref"] == 0) & (df["sumref2"] == 2))]

df_with_2_ref.to_csv('bverfg230107_with_2_ref.csv', index=False)
print(len(df_with_2_ref.index))  #3192 cases

df_with_2_ref = pd.read_csv('bverfg230107_with_2_ref.csv')[rf_columns]

#Get a df with a column showing all features (ref...) that have value = 1 in each row (expect 2 features or 2 referees per row)
#df_with_ref_variable = df_with_2_ref.idxmax(axis=1)
df_with_ref_variable = df_with_2_ref.apply(lambda row: list(row[row == 1].index), axis=1)

#print('head_ref:', df_with_ref_variable.head())

df_with_uid = pd.read_csv('bverfg230107_with_2_ref.csv')['uid']
#print('head_uid:', df_with_uid.head())
df_with_uid_and_ref_variable = pd.concat([df_with_uid, df_with_ref_variable], axis=1)
#rename columns
df_with_uid_and_ref_variable.columns = ['uid', 'referees']

df_with_uid_and_ref_variable.to_csv('bverfg230107_with_uid_and_2ref_variable.csv', index=False)
df_with_uid_and_ref_variable.to_pickle("bverfg230107_with_uid_and_2ref_variable.pkl")
'''


#Use the saved ground-truth df of uid and 2 referees
df_with_uid_and_ref_variable = pd.read_pickle("bverfg230107_with_uid_and_2ref_variable.pkl")
print('df_with_uid_and_ref_variable.head():', df_with_uid_and_ref_variable.head())

#Scenario 1
#True: A, B
#Predict: A, C
#TP = 1, FP = 1 (C), FN = 1 (B) => precision = 1/2 = recall

#Scenario 2
#True: A, B
#Predict: C, D
#TP = 0, FP = 2 (C, D), FN = 1 (A, B) => precision = 0 = recall

#Scenario 3
#True: A, B
#Predict: A, B
#TP = 2, FP = 0, FN = 0 => precision = 1 = recall

#Iterate through each row in df_with_uid_and_ref_variable and check if the ref is the same as (mappable to) the top author
#in the per-document distribution of authors

precision_list = []

print('ref_to_author_dict:', ref_to_author_dict)
print('ref_to_author_dict[ref2bross]:', ref_to_author_dict['ref2_bross'])

for index, row in df_with_uid_and_ref_variable.iterrows():
    uid = row['uid']
    ground_truth_referees = row['referees']
    ground_truth_authors = [ref_to_author_dict[ref] for ref in ground_truth_referees]
    ATM_top2_authors = top2authors_per_doc[uid]

    if ground_truth_referees[0] in ref_to_author_dict and ground_truth_referees[1] in ref_to_author_dict:
        intersection = list(set(ground_truth_authors) & set(ATM_top2_authors))
        #print('ground_truth_authors:', ground_truth_authors)
        #print('ATM_top2_authors:', ATM_top2_authors)
        #print('intersection:', intersection)
        #print('len(intersection):', len(intersection))
        if len(intersection) == 2:
            precision_list += [1]
        elif len(intersection) == 1:
            precision_list += [0.5]
        elif len(intersection) == 0:
            precision_list += [0]

print('precision_list:', precision_list)
avg_precision = np.mean(precision_list)
print('avg_precision:', avg_precision)


#Results:
#num_topics = 50 -> avg_precision: 0.676530612244898
#num_topics = 100 -> avg_precision:  0.6697278911564626
#num_topics = 200 -> avg_precision:  0.6802721088435374



