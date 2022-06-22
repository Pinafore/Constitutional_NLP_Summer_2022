# -*- coding: utf-8 -*-
"""
Created on Fri Jun 17 17:25:05 2022

@author: Acer
"""
#topics (i.e. dockets) = 37

#Tutorial: https://github.com/rsreetech/LDATopicModelling
# https://www.youtube.com/watch?v=nNvPvvuPnGs

import pandas as pd
#import numpy as np

#import re
import string

import spacy

import gensim
from gensim import corpora

# libraries for visualization
#import pyLDAvis
#import pyLDAvis.gensim
#import matplotlib.pyplot as plt
#import seaborn as sns

col_list = ["bverfg_id", "full_text"]
df_full_text = pd.read_csv("20200929_bverfg_cases.csv", usecols=col_list)
#df_full_text.head()

print('Number of rulings =', len(df_full_text))

def clean_text(text): 
    delete_dict = {sp_character: '' for sp_character in string.punctuation} 
    delete_dict[' '] = ' ' 
    table = str.maketrans(delete_dict)
    text1 = text.translate(table)
    #print('cleaned:'+text1)
    textArr= text1.split()
    text2 = ' '.join([w for w in textArr if ( not w.isdigit() and  ( not w.isdigit() and len(w)>3))]) 
    
    return text2.lower()

#import nltk
#nltk.download('stopwords') # run this one time

df_full_text.dropna(axis = 0, how ='any',inplace=True) 

df_full_text['full_text'] = df_full_text['full_text'].apply(clean_text)
#df_full_text['Num_words_text'] = df_full_text['Text'].apply(lambda x:len(str(x).split())) 

print('after clean_text: df_full_text=', df_full_text)

#
from nltk.corpus import stopwords
stop_words = stopwords.words('german')
# function to remove stopwords
def remove_stopwords(text):
    textArr = text.split(' ')
    rem_text = " ".join([i for i in textArr if i not in stop_words])
    return rem_text
#

#df_sampled = df_full_text.groupby('bverfg_id').apply(lambda x: x.sample(frac=0.1, replace=True)).reset_index(drop = True)
df_sampled = df_full_text
print('df_sampled=', df_sampled)

#
# remove stopwords from the text
df_sampled['full_text']=df_sampled['full_text'].apply(remove_stopwords)

print('after remove_stopwords: df_sampled=', df_sampled)
#

nlp = spacy.load('de_core_news_md', disable=['parser', 'ner'])

def lemmatization(texts,allowed_postags=['NOUN', 'ADJ']): 
       output = []
       for sent in texts:
             doc = nlp(sent)     #dr 37304
             #doc = sent #dr 36312
             output.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
       return output

text_list=df_sampled['full_text'].tolist()
print('text_list =', text_list)
tokenized_rulings = lemmatization(text_list)
print('tokenized_rulings =', tokenized_rulings)

dictionary = corpora.Dictionary(tokenized_rulings)
doc_term_matrix = [dictionary.doc2bow(rul) for rul in tokenized_rulings]

# Creating the object for LDA model using gensim library
LDA = gensim.models.ldamodel.LdaModel

# Build LDA model
#lda_model = LDA(corpus=doc_term_matrix, id2word=dictionary, num_topics=37, random_state=1,
#               chunksize=1000, passes=10,iterations=5)
lda_model = LDA(corpus=doc_term_matrix, id2word=dictionary, num_topics=37, random_state=1)#, iterations=5)
topics = lda_model.print_topics(num_topics=37, num_words=10)
topics_file = open("topics.txt", "w")
n = topics_file.write(str(topics))
topics_file.close()