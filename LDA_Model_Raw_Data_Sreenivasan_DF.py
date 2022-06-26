# -*- coding: utf-8 -*-
"""
Created on Fri Jun 17 17:25:05 2022

@author: Acer
"""
#topics (i.e. dockets) = 37

#Tutorial: https://github.com/rsreetech/LDATopicModelling
# https://www.youtube.com/watch?v=nNvPvvuPnGs
import numpy as np
import pandas as pd
#import numpy as np

#import re
import string

import spacy

import gensim
from gensim import corpora
from nltk.corpus import stopwords

def LDA_Model_with_DF_stopwords(DF_threshold):
    col_list = ["bverfg_id", "full_text"]
    df_full_text = pd.read_csv("20200929_bverfg_cases.csv", usecols=col_list)
    #df_full_text.head()
    print('df_full_text.shape =', df_full_text.shape)
    #print('Number of rulings =', len(df_full_text))
    
    def clean_text(text): 
        delete_dict = {sp_character: '' for sp_character in string.punctuation} 
        delete_dict[' '] = ' ' 
        table = str.maketrans(delete_dict)
        text1 = text.translate(table)
        textArr= text1.split()
        text2 = ' '.join([w for w in textArr if ( not w.isdigit() and  ( not w.isdigit() and len(w)>3))]) 
        
        return text2.lower()
    
    #import nltk
    #nltk.download('stopwords') # run this one time
    
    df_full_text.dropna(axis = 0, how ='any',inplace=True) 
    print('df_full_text.shape after dropna =', df_full_text.shape)
    df_full_text['full_text'] = df_full_text['full_text'].apply(clean_text)
    
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
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + ".txt", "w")
    n = stopword_DF_file.write(str(stopword_DF))
    stopword_DF_file.close()
    '''
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + ".txt", "r")
    stopword_DF = stopword_DF_file.read()
    stopword_DF_file.close()
    '''
    stop_words = stop_words + stopword_DF
    print('len(stop_words) =', len(stop_words))
    
    # function to remove stopwords
    def remove_stopwords(text):
        textArr = text.split(' ')
        print('', np.array(textArr).shape)
        rem_text = " ".join([i for i in textArr if i not in stop_words])
        return rem_text
    
    #df_sampled = df_full_text.groupby('bverfg_id').apply(lambda x: x.sample(frac=0.1, replace=True)).reset_index(drop = True)
    df_sampled = df_full_text
    #print('df_sampled=', df_sampled)
    
    # remove stopwords from the text
    df_sampled['full_text']=df_sampled['full_text'].apply(remove_stopwords)
    
    #print('after remove_stopwords: df_sampled=', df_sampled)
    
    nlp = spacy.load('de_core_news_md', disable=['parser', 'ner'])
    
    def lemmatization(texts,allowed_postags=['NOUN', 'ADJ']): 
           output = []
           for sent in texts:
                 doc = nlp(sent)     #dr 37304
                 #doc = sent #dr 36312
                 output.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
           return output
    
    text_list=df_sampled['full_text'].tolist()
    #print('text_list =', text_list)
    tokenized_rulings = lemmatization(text_list)
    #print('tokenized_rulings =', tokenized_rulings)
    
    #Compute document frequency of every token
    dictionary = corpora.Dictionary(tokenized_rulings)
    doc_term_matrix = [dictionary.doc2bow(rul) for rul in tokenized_rulings]
    
    # Creating the object for LDA model using gensim library
    LDA = gensim.models.ldamodel.LdaModel
    
    # Build LDA model
    lda_model = LDA(corpus=doc_term_matrix, id2word=dictionary, num_topics=37, random_state=1)#, iterations=5)
    topics = lda_model.print_topics(num_topics=37, num_words=10)
    topics_file = open("topics_DF_threshold=" + str(DF_threshold) + ".txt", "w")
    n = topics_file.write(str(topics))
    topics_file.close()
    
LDA_Model_with_DF_stopwords(DF_threshold=500)
LDA_Model_with_DF_stopwords(DF_threshold=1000)
LDA_Model_with_DF_stopwords(DF_threshold=2000)
LDA_Model_with_DF_stopwords(DF_threshold=4000)
LDA_Model_with_DF_stopwords(DF_threshold=7500)