# -*- coding: utf-8 -*-
"""
Created on Sun Jun 12 21:35:18 2022

@author: Acer
"""
#Documentation: https://radimrehurek.com/gensim/models/atmodel.html?fbclid=IwAR1WbQOM-vCFzfEiwqUOrXISNGZJIeppILYiqSJEUd2DvNkuHKOV6dJISgI
#Tutorial: https://nbviewer.org/github/rare-technologies/gensim/blob/develop/docs/notebooks/atmodel_tutorial.ipynb

import numpy as np
import pandas as pd
import string
import json
import argparse

import spacy

import gensim
from gensim import corpora

from nltk.corpus import stopwords
stop_words = stopwords.words('german')

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

def remove_stopwords(text):
    textArr = text.split(' ')
    rem_text = " ".join([i for i in textArr if i not in stop_words])
    return rem_text

def clean_text(text):
    
    delete_dict = {sp_character: '' for sp_character in string.punctuation} 
    delete_dict[' '] = ' ' 
    table = str.maketrans(delete_dict)
    text1 = text.translate(table)
    #print('cleaned:'+text1)
    textArr= text1.lower().split()
    text2 = ' '.join([w for w in textArr if ( not w.isdigit() and  ( not w.isdigit() and (not w in stop_words) and len(w)>3))]) 
    
    return text2

def read_cases(filename, limit=-1):
    col_list = ["bverfg_id", "full_text"]

    if limit > 0:
        df_full_text = pd.read_csv(filename, usecols=col_list, nrows=limit)
    else:
        df_full_text = pd.read_csv(filename, usecols=col_list)

    df_full_text.dropna(axis = 0, how ='any',inplace=True) 

    df_full_text['full_text'] = df_full_text['full_text'].apply(clean_text)

    text_list = lemmatization(df_full_text)
    doc_term_matrix = create_term_matrix(text_list)
    
    return doc_term_matrix


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

    return doc_term_matrix


def fit_model(dataset, author_participation, output_filename, num_topics):
    from gensim.models import AuthorTopicModel
    
    model = AuthorTopicModel(corpus=dataset,
                             num_topics=flags.num_topics,
                             author2doc=author_participation,
                             chunksize=200, passes=1, eval_every=0, iterations=1, random_state=1)

    model.save(output_filename)
    return model

def load_model(filename):
    return AuthorTopicModel.load('Author_Topic_model.atmodel')


if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Fit AT on court cases")
  parser.add_argument('--limit', type=int,
                      default=-1, help="Limit of number of cases")
  parser.add_argument('--author_list', type=str,
                      default="author2doc.json")
  parser.add_argument('--cases_source', type=str,
                      default="20200929_bverfg_cases.csv")
  parser.add_argument('--model_save', type=str,
                      default="at_model.save")
  parser.add_argument('--num_topics', type=int, default=40)
  
  flags = parser.parse_args()

  cases = read_cases(flags.cases_source, limit=flags.limit)
  if flags.limit > 0:
      author_participation = case_participation(flags.author_list, flags.limit)
  else:
      author_participation = case_participation(flags.author_list, len(cases))    
  model = fit_model(cases, author_participation,
                    flags.model_save, num_topics=flags.num_topics)
  
  

# construct vectors for authors
# author_vecs = [model.get_author_topics(author) for author in model.id2author.values()]
# print('author_vecs =', author_vecs)
# author_vecs_file = open("Author_Topic_Model_author_vecs.txt", "w")
# n = author_vecs_file.write(str(author_vecs))
# author_vecs_file.close()

