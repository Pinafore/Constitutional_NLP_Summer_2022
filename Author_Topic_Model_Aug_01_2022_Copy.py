# -*- coding: utf-8 -*-
"""
Created on Sat Jul 30 06:47:39 2022

@author: Acer
"""

import numpy as np
import pandas as pd
import string
import json
import argparse

import spacy

import gensim
from gensim import corpora

from nltk.corpus import stopwords

def case_participation(filename, limit):
    """
    Make a dictionary author2doc of which cases (documents) each justice
    participates in
    """
    # col_list = ["bverfg_id", "participating_judges"]
    # df = pd.read_csv("20200929_bverfg_cases.csv", usecols=col_list)

    with open(filename, "r") as a_file:
        author2doc = a_file.read()

        author2doc = json.loads(author2doc) #convert str to dict

    # Remove all out of range documents
    for author in author2doc:
        author2doc[author] = [x for x in author2doc[author] if x < limit]
    
    return author2doc


def construct_stopwords(DF_threshold):
    col_list = ["bverfg_id_forward", "full_text"]
    df_full_text = pd.read_csv('case_scraping_Aug_01_2022.csv', usecols=col_list)
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
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "w")
    n = stopword_DF_file.write(str(stopword_DF))
    stopword_DF_file.close()
    
    '''
    stopword_DF_file = open("stopwords_DF_threshold=" + str(DF_threshold) + "_Aug_01_2022.txt", "r")
    stopword_DF = stopword_DF_file.read()
    stopword_DF_file.close()
    '''
    stop_words = stop_words + stopword_DF
    print('len(stop_words) =', len(stop_words))
    return stop_words


def remove_stopwords(text):
    stop_words = construct_stopwords(DF_threshold=1000)
    textArr = text.split(' ')
    rem_text = " ".join([i for i in textArr if i not in stop_words])
    return rem_text



def clean_text(text):
    stop_words = construct_stopwords(DF_threshold=1000)
    delete_dict = {sp_character: '' for sp_character in string.punctuation} 
    delete_dict[' '] = ' ' 
    table = str.maketrans(delete_dict)
    text1 = text.translate(table)
    #print('cleaned:'+text1)
    textArr= text1.lower().split()
    text2 = ' '.join([w for w in textArr if ( not w.isdigit() and  ( not w.isdigit() and (not w in stop_words) and len(w)>3))]) 
    
    return text2

def read_cases(filename, limit=-1):
    col_list = ["bverfg_id_forward", "full_text"]

    if limit > 0:
        df_full_text = pd.read_csv(filename, usecols=col_list, nrows=limit)
    else:
        df_full_text = pd.read_csv(filename, usecols=col_list)

    df_full_text.dropna(axis = 0, how ='any',inplace=True) 

    df_full_text['full_text'] = df_full_text['full_text'].apply(clean_text)
    df_full_text['full_text'] = df_full_text['full_text'].apply(remove_stopwords)

    text_list = lemmatization(df_full_text)
    doc_term_matrix = create_term_matrix(text_list)
    
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


def fit_model(dictionary, dataset, author_participation, output_filename, num_topics):
    from gensim.models import AuthorTopicModel
    
    model = AuthorTopicModel(corpus=dataset,
                             num_topics=flags.num_topics,
                             author2doc=author_participation, 
                             id2word=dictionary, random_state=1)#,
                             #chunksize=200, passes=1, eval_every=0, iterations=1, random_state=1)

    model.save(output_filename)
    return model
 
    
def load_model(filename):
    return AuthorTopicModel.load('Author_Topic_model.atmodel')


def output_author_vecs(model):
    author_vecs_file = open("at_model_author_vecs.txt", "w")
    author_vecs = ''
    for author in model.id2author.values():
        sorted_author_topics = sorted(model.get_author_topics(author), key=lambda x: x[1], reverse=True)
        author_vecs = author_vecs + str(author) + ': ' + str(sorted_author_topics) + '\n'
    print('author_vecs =', author_vecs)
    author_vecs_file = open("at_model_author_vecs.txt", "w")
    n = author_vecs_file.write(str(author_vecs))
    author_vecs_file.close()
    return author_vecs_file


def output_topics(model, num_topics):
    #topics = model.print_topics(num_topics=37, num_words=10)
    topics = ''
    for topic_id in range(num_topics):
        sorted_topic_terms = sorted(model.get_topic_terms(topic_id, topn=10), key=lambda x: x[1], reverse=True)
        topics += str(topic_id) + ': ' + str(sorted_topic_terms) + '\n'
    print('topics =', topics)
    topics_file = open("at_model_topics.txt", "w")
    n = topics_file.write(str(topics))
    topics_file.close()
    return topics_file

if __name__ == "__main__":
    
  parser = argparse.ArgumentParser(description="Fit AT on court cases")
  parser.add_argument('--limit', type=int,
                      default=-1, help="Limit of number of cases")
  parser.add_argument('--author_list', type=str,
                      default="author2doc_Aug_01_2022.json")
  parser.add_argument('--cases_source', type=str,
                      default="case_scraping_Aug_01_2022.csv")
  parser.add_argument('--model_save', type=str,
                      default="at_model.save")
  parser.add_argument('--num_topics', type=int, default=37)
  parser.add_argument('--DF_threshold', type=int, default=1000)
  
  flags = parser.parse_args()
  
  dictionary, doc_term_matrix = read_cases(flags.cases_source, limit=flags.limit)
  #cases = read_cases(flags.cases_source, limit=flags.limit)
  if flags.limit > 0:
      author_participation = case_participation(flags.author_list, flags.limit)
  else:
      author_participation = case_participation(flags.author_list, len(doc_term_matrix))    
      model = fit_model(dictionary, doc_term_matrix, author_participation,
                  flags.model_save, num_topics=flags.num_topics)
      
#  author_participation = case_participation(flags.author_list, len(cases))    
#  model = fit_model(cases, author_participation,
#                    flags.model_save, num_topics=flags.num_topics)
  author_vecs_file = output_author_vecs(model)
  topics_file = output_topics(model, num_topics = flags.num_topics)
  
  
#get_topic_terms, print_topic, print_topics, show_topic, show_topics all return (word id, probability) rather than (word str, probability) 