import pandas as pd
import json
import re
import numpy as np
import pickle

num_topics = 50

df = pd.read_csv('bverfg230107_with_break_noNaN.csv')
columns = list(df.columns)
rf_columns = []
for col in columns:
    if col[:3] == 'ref':
        #print('col:', col)
        rf_columns.append(col)

#print('rf_columns:', rf_columns)
#print('len(rf_columns):', len(rf_columns)) # 50


with open('WardNJU_authors_per_doc_topN=1_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    authors_prob_per_doc_all = pickle.load(f)  #format: {0: {'winter': 0.42},...}

author_per_doc = {}
for k, v in authors_prob_per_doc_all.items():
    #print(k)
    if len(list(v.keys())) > 0:
        author_per_doc[k] = list(v.keys())[0]
    else:
        author_per_doc[k] = np.nan
#print(author_per_doc.values())
unique_authors = np.unique(list(author_per_doc.values()))
#print('unique_authors:', unique_authors)
#print('len(unique_authors):', len(unique_authors)) #53

#Construct a map from referee to author variable (e.g. ref_kuehling -> kuehling)
ref_to_author_dict = {}
for author in unique_authors:
    for ref in rf_columns:
        if (author == ref[4:]) | (author == ref[5:]):
            print('author:', author)
            print('ref:', ref)
            ref_to_author_dict[ref] = author
print('ref_to_author_dict:', ref_to_author_dict)
print('len(ref_to_author_dict):', len(ref_to_author_dict)) #50

df_with_unqiue_ref = df[((df["sumref"] == 1) & (df["sumref2"] == 0)) | ((df["sumref"] == 0) & (df["sumref2"] == 1))]

df_with_unqiue_ref.to_csv('bverfg230107_with_unique_ref.csv', index=False)
#print(len(df_with_unqiue_ref.index))  #3192 cases

df_with_unqiue_ref = pd.read_csv('bverfg230107_with_unique_ref.csv')[rf_columns]

df_with_ref_variable = df_with_unqiue_ref.idxmax(axis=1)
#print('head_ref:', df_with_ref_variable.head())

df_with_uid = pd.read_csv('bverfg230107_with_unique_ref.csv')['uid']
#print('head_uid:', df_with_uid.head())
df_with_uid_and_ref_variable = pd.concat([df_with_uid, df_with_ref_variable], axis=1)
#rename columns
df_with_uid_and_ref_variable.columns = ['uid', 'referee']

df_with_uid_and_ref_variable.to_csv('bverfg230107_with_uid_and_ref_variable.csv', index=False)
df_with_uid_and_ref_variable = pd.read_csv('bverfg230107_with_uid_and_ref_variable.csv')
#print(df_with_uid_and_ref_variable.head())

#Iterate through each row in df_with_uid_and_ref_variable and check if the ref is the same as (mappable to) the top author
#in the per-document distribution of authors
accuracy_nom = 0
accuracy_denom = 0
for index, row in df_with_uid_and_ref_variable.iterrows():
    uid = row['uid']
    referee = row['referee']
    if referee in ref_to_author_dict:
        accuracy_denom +=1
        mapped_author = ref_to_author_dict[referee]
        top_author = author_per_doc[uid]

        print('uid:', uid)
        print('top_author:', top_author)
        print('referee:', referee)
        print('mapped_author:', mapped_author)
        if mapped_author == top_author:
            accuracy_nom += 1

print('accuracy_nom:', accuracy_nom)
print('accuracy_denom:', accuracy_denom)
accuracy = accuracy_nom/accuracy_denom
print('accuracy:', accuracy)
