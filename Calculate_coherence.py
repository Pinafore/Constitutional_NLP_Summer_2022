"""
Time: Thu Dec 15

@author: Jiannan, Tin
"""

import pandas as pd
import json
import pickle
import itertools
import math
import seaborn as sns
import matplotlib.pyplot as plt
from statistics import median


def calculate_coherence(doc_words,topics,flag):
    score_dict = {}
    for j in range(0,len(topics.keys())):
        score = 0
        if flag == 'AT':
            topics_words = [topics[j][i][1] for i in range(0,len(topics[j]))]
        if flag == 'LDA':
            topics_words = [topics[str(j)][i] for i in range(0,len(topics[str(j)]))]
        for pair in itertools.combinations_with_replacement(topics_words,2):
            d_w1 = [pair[1] in doc_words[i] for i in range(0,len(doc_words))]
            num_d_w1 = d_w1.count(True)
            d_w1_w2 = [pair[0] in doc_words[i] and pair[1] in doc_words[i] for i in range(0,len(doc_words))]
            num_d_w1_w2 = d_w1_w2.count(True)
            score += math.log((num_d_w1_w2 + 1)/num_d_w1)
        score_dict[j] = score
    return score_dict


if __name__ == "__main__":
    with open('Data/read_cases_manualATM_text_list.json', 'r') as f:
        read_cases_manualATM_text_list = json.load(f)
    with open('Data/WardNJU_words_per_topic_num_topics=' + str(10) + '.json', 'rb') as f:
        topics_AT_10 = pickle.load(f)    
    with open('Data/WardNJU_words_per_topic_num_topics=' + str(50) + '.json', 'rb') as f:
        topics_AT_50 = pickle.load(f)
    with open('Data/WardNJU_words_per_topic_num_topics=' + str(100) + '.json', 'rb') as f:
        topics_AT_100 = pickle.load(f)
    with open('Data/WardNJU_words_per_topic_num_topics=' + str(200) + '.json', 'rb') as f:
        topics_AT_200 = pickle.load(f)
    with open('Data/LDA_formatted_top10_words_per_topic_num_topics=' + str(50) + '.json', 'rb') as f:
        topics_LDA_50 = json.load(f)
    
    score_dict_AT_10 = calculate_coherence(read_cases_manualATM_text_list,topics_AT_10,'AT')
    with open('Output/score_dict_AT_10.txt', 'w') as convert_file:
        convert_file.write(json.dumps(score_dict_AT_10))
    mean_score_dict_AT_10 = sum(score_dict_AT_10.values())/len(score_dict_AT_10.values())
    median_score_dict_AT_10 = median(score_dict_AT_10)

    score_dict_AT_50 = calculate_coherence(read_cases_manualATM_text_list,topics_AT_50,'AT')
    with open('Output/score_dict_AT_50.txt', 'w') as convert_file:
        convert_file.write(json.dumps(score_dict_AT_50))
    mean_score_dict_AT_50 = sum(score_dict_AT_50.values())/len(score_dict_AT_50.values())
    median_score_dict_AT_50 = median(score_dict_AT_50)

    score_dict_AT_100 = calculate_coherence(read_cases_manualATM_text_list,topics_AT_100,'AT')
    with open('Output/score_dict_AT_100.txt', 'w') as convert_file:
        convert_file.write(json.dumps(score_dict_AT_100))
    mean_score_dict_AT_100 = sum(score_dict_AT_100.values())/len(score_dict_AT_100.values())
    median_score_dict_AT_100 = median(score_dict_AT_100)


    score_dict_AT_200 = calculate_coherence(read_cases_manualATM_text_list,topics_AT_200,'AT')
    with open('Output/score_dict_AT_200.txt', 'w') as convert_file:
        convert_file.write(json.dumps(score_dict_AT_200))
    mean_score_dict_AT_200 = sum(score_dict_AT_200.values())/len(score_dict_AT_200.values())
    median_score_dict_AT_200 = median(score_dict_AT_200)

    # print('score_dict_AT_50\n',score_dict_AT_50)
    # print('score_dict_AT_100\n',score_dict_AT_100)
    # print('score_dict_AT_200\n',score_dict_AT_200)
    print('avaerage score_dict_AT\n', mean_score_dict_AT_10,mean_score_dict_AT_50,mean_score_dict_AT_100,mean_score_dict_AT_200)
    print('meidan score_dict_AT\n', median_score_dict_AT_10, median_score_dict_AT_50,median_score_dict_AT_100,median_score_dict_AT_200)
    score_dict_LDA = calculate_coherence(read_cases_manualATM_text_list,topics_LDA_50,'LDA')
    with open('Output/score_dict_LDA.txt', 'w') as convert_file:
        convert_file.write(json.dumps(score_dict_LDA))
    print('score_dict_LDA\n',score_dict_LDA)
    print('avaerage score_dict_LDA', sum(score_dict_LDA.values())/len(score_dict_LDA.values()))

    #df = pd.DataFrame(data = {'Number of topics': [50, 100, 200], 'Coherence score': [mean_score_dict_AT_50, mean_score_dict_AT_100,mean_score_dict_AT_200]})
    df = pd.DataFrame(data = {'Number of topics': [10, 50, 100, 200], 'Average coherence score':[mean_score_dict_AT_10,-80.79144560414673,-95.62740792339578,-86.47907316046178]})
    plt.plot(df['Number of topics'], df['Average coherence score'], marker="o")
    #sns.lineplot(data=df,x="Number of topics", y="Coherence score", markers=True, dashes=False)
    plt.show()
    df_median = pd.DataFrame(data = {'Number of topics': [10, 50, 100, 200], 'Median coherence score':[median_score_dict_AT_10,median_score_dict_AT_50,median_score_dict_AT_100,median_score_dict_AT_200]})
    plt.plot(df_median['Number of topics'], df_median['Median coherence score'], marker="o")
    plt.show()

