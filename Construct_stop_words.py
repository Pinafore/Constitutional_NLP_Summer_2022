# -*- coding: utf-8 -*-
"""
Created on Mon Aug  1 05:52:52 2022

@author: Acer
"""
import numpy as np
import pandas as pd
import argparse
from nltk.corpus import stopwords
import json 

def construct_stopwords(df_full_text, DF_threshold):
    stop_words = stopwords.words('german')
    print('np.array(stop_words).shape =', np.array(stop_words).shape)
    
    df_full_text_col = df_full_text['full_text']
    print('df_full_text_col.shape=', df_full_text_col.shape)
    print('len(df_full_text_col) =', len(df_full_text_col))
    DF = {}
    for doc_id in range(len(df_full_text_col)):
        try:
            tokens = df_full_text_col[doc_id].split(' ')
            #print('tokens =', tokens)
            for w in tokens:
                try:
                    DF[w].add(doc_id)
                except:
                    DF[w] = {doc_id}
        except:
            continue

    stopword_DF = []
    for w in DF:
        DF[w] = len(DF[w])
        if DF[w] > DF_threshold:
            stopword_DF.append(w)
    #print('DF =', DF)
    #print('stopword_DF =', stopword_DF)
    print('len(stopword_DF) =', len(stopword_DF))
    with open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "w") as fp:
        json.dump(stopword_DF, fp)
    with open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "r") as fp:
        stopword_DF = json.load(fp)

    '''
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "w")
    n = stopword_DF_file.write(str(stopword_DF))
    stopword_DF_file.close()
    
    
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "r")
    stopword_DF = stopword_DF_file.read()
    stopword_DF_file.close()
    '''
    stop_words = stop_words + stopword_DF
    
    with open("stop_words_Aug_01_2022.txt", "w") as fp:
        json.dump(stop_words, fp)
    with open("stop_words_Aug_01_2022.txt", "r") as fp:
        stop_words = json.load(fp)
    
    print('len(stop_words) =', len(stop_words))
    return stop_words

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Construct stopwords based on DF")
    parser.add_argument('--DF_threshold', type=int, default=1000)
    flags = parser.parse_args()
    col_list = ["bverfg_id_forward", "full_text"]
    df_full_text = pd.read_csv('case_scraping_Aug_01_2022.csv', usecols=col_list)
    stop_words = construct_stopwords(df_full_text, DF_threshold=flags.DF_threshold)
