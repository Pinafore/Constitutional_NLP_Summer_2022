import json
import pandas as pd
import datetime
from collections import defaultdict
import numpy as np
import pickle


from difflib import SequenceMatcher


def clean_german_chars(string: str) -> str:

    tpl: tuple = (
        ('ü', "ue"), ('Ü', "Ue"), ('ä', "ae"), ('Ä', "Ae"), ("ö", "oe"),
        ('Ö', "Oe"), ('ß', "ss")
    )

    for item1, item2 in tpl:
        string = string.replace(item1, item2)

    return string


def get_dict_of_dict_time_judge_domain(file_name):
    df = pd.read_csv(file_name, skiprows=[0])
    df['corrbegin'] = pd.to_datetime(df['corrbegin'])
    df['corrend'] = pd.to_datetime(df['corrend'])
    #print(df.head())
    dict_of_dict_time_judge_domain = {}
    #check_date = pd.to_datetime('2020-05-21')

    domains = df.columns[4:]
    #print('domains:', domains)
    #print('len(domains):', len(domains)) #79 for SenateI

    for index, row in df.iterrows():
        #Since a list cannot be a key in dict, we record the begin and end date as a tuple to be a key in dict
        begin_end_tuple = (row['corrbegin'], row['corrend'])
        #print('begin_end_tuple:', begin_end_tuple)

        dict_of_dict_time_judge_domain[begin_end_tuple] = {}

        for domain in domains:
            judge = row[domain]
            if domain[-1].isdigit(): #take care of domains like 'tax.2'
                domain = domain[:-2]
            if file_name == 'SenatI_full_corr.csv':
                domain = 'dm_' + domain
            if file_name == 'SenatII_full_corr.csv':
                domain = 'dm2_' + domain
            #print('domain:', domain)
            #print('judge:', judge)
            #print('type(judge):', type(judge))
            if not (pd.isna(domain) or pd.isna(judge)):
                judge = clean_german_chars(judge.lower())
                if judge not in dict_of_dict_time_judge_domain[begin_end_tuple]:
                    dict_of_dict_time_judge_domain[begin_end_tuple][judge] = [domain] #bug (cannot afford judges with multiple domains)
                else:
                    dict_of_dict_time_judge_domain[begin_end_tuple][judge] += [domain]
    #print('dict_of_dict_time_judge_domain:', dict_of_dict_time_judge_domain)

    return dict_of_dict_time_judge_domain
        #if begin_end_tuple[0] <= check_date <= begin_end_tuple[1]:
        #    print('date match!')



dict_of_dict_time_judge_domain_1 = get_dict_of_dict_time_judge_domain('SenatI_full_corr.csv')
dict_of_dict_time_judge_domain_2 = get_dict_of_dict_time_judge_domain('SenatII_full_corr.csv')

dict_of_dict_time_judge_domain = {}

for time in dict_of_dict_time_judge_domain_1.keys():
    if time in dict_of_dict_time_judge_domain_2:
        # merge two dicts
        dict_of_dict_time_judge_domain[time] = dict_of_dict_time_judge_domain_1[time] | dict_of_dict_time_judge_domain_2[time]
    else:
        dict_of_dict_time_judge_domain[time] = dict_of_dict_time_judge_domain_1[time]

for time in dict_of_dict_time_judge_domain_2.keys():
    if not(time in dict_of_dict_time_judge_domain_1):
        dict_of_dict_time_judge_domain[time] = dict_of_dict_time_judge_domain_2[time]

print('dict_of_dict_time_judge_domain_1:', dict_of_dict_time_judge_domain_1)
print('dict_of_dict_time_judge_domain_2:', dict_of_dict_time_judge_domain_2)
print('dict_of_dict_time_judge_domain:', dict_of_dict_time_judge_domain)


df = pd.read_csv('bverfg230107_with_break_noNaN_w_additional_features_and_clean_judges.csv', low_memory=False)
#df = df[['uid', 'date', 'clean_judges']]
#Get the first 50 rows to test
#df = df.head(50)

df['domains_of_judges'] = ''



for row_index, row in df.iterrows():
    case_date = pd.to_datetime(row['date'])
    relevant_domain_list = []


    for begin_end_tuple in dict_of_dict_time_judge_domain.keys():
        if begin_end_tuple[0] <= case_date <= begin_end_tuple[1]:
            case_authors = row['clean_judges']
            case_authors = case_authors.replace("'", "") #remove the quote (') characters from the string ,e.g. 'seidl' -> seidl
            #print('case_authors:', case_authors)
            period_author_domain_dict = dict_of_dict_time_judge_domain[begin_end_tuple]
            #print('period_author_domain_dict:', period_author_domain_dict)
            for case_author in case_authors[1:-1].split(', '):
                #print('case_author:', case_author)
                if case_author in period_author_domain_dict:
                    #print('relevant case_author:', case_author)
                    relevant_domains = period_author_domain_dict[case_author]
                    #print('relevant_domain:', relevant_domain)
                    relevant_domain_list += relevant_domains

    #print('relevant_domain_list:', relevant_domain_list)
    df.at[row_index, 'domains_of_judges'] = relevant_domain_list

df.to_csv('bverfg230107_with_break_noNaN_w_time_aware_features.csv')
#df.to_csv('few_cols_bverfg230107_with_break_noNaN_w_time_aware_features.csv')