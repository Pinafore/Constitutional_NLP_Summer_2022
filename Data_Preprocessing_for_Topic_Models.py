# -*- coding: utf-8 -*-
"""
Created on Thu Aug  4 18:34:51 2022

@author: Acer
"""

import pandas as pd
import string
import json
import spacy

from gensim import corpora

from nltk.tokenize import word_tokenize
import nltk
nltk.download('punkt')

def case_participation(filename, limit):
    """
    Make a dictionary author2doc of which cases (documents) each justice
    participates in
    """

    with open(filename, "r") as a_file:
        author2doc = a_file.read()

        author2doc = json.loads(author2doc) #convert str to dict

    # Remove all out of range documents
    for author in author2doc:
        author2doc[author] = [x for x in author2doc[author] if x < limit]
    
    return author2doc

def clean_text(text):
    #with open("stopwords_DF_threshold=500.txt", "r") as fp:
    print('text:', text)
    with open("stop_words_Aug_01_2022.txt", "r") as fp:
        stop_words = json.load(fp)
    '''
    stop_words_set = set(stop_words)

    word_tokens = word_tokenize(text)
    filtered_text = [w for w in word_tokens if len(w)>3 and (not any(char.isdigit() for char in w)) and (not w in stop_words_set)]

    print('filtered_text:', filtered_text)
    print('stop_words_set:', stop_words_set)
    return filtered_text
    '''
    delete_dict = {sp_character: '' for sp_character in string.punctuation} 
    delete_dict[' '] = ' ' 
    table = str.maketrans(delete_dict)
    text1 = text.translate(table)
    #print('cleaned:'+text1)
    #textArr= text1.lower().split()
    textArr = text1.split()
    #delete tokens that contains number, tokens in stop word list, and too short tokens
    text2 = ' '.join([w for w in textArr if (not any(char.isdigit() for char in w)) and (not w in stop_words) and len(w)>3])
    print('text2:', text2)
    return text2 




def read_cases(filename, limit=-1):
    col_list = ["bverfg_id_forward", "full_text"]

    if limit > 0:
        df_full_text = pd.read_csv(filename, usecols=col_list, nrows=limit)
    else:
        df_full_text = pd.read_csv(filename, usecols=col_list)

    df_full_text.dropna(axis = 0, how ='any',inplace=True) 

    df_full_text['full_text'] = df_full_text['full_text'].apply(clean_text)

    text_list = lemmatization(df_full_text)
    dictionary, doc_term_matrix = create_term_matrix(text_list)
    
    return dictionary, doc_term_matrix


def lemmatization(text_df, allowed_postags=['NOUN', 'ADJ']):
    nlp = spacy.load('de_core_news_md', disable=['parser', 'ner'])
    texts = text_df['full_text'].tolist()    
    output = []
    for sent in texts:
        doc = nlp(sent)     
        output.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
    return output


def create_term_matrix(tokenized_rulings):
    dictionary = corpora.Dictionary(tokenized_rulings)
    doc_term_matrix = [dictionary.doc2bow(rul) for rul in tokenized_rulings]

    return dictionary, doc_term_matrix