# -*- coding: utf-8 -*-
"""
Created on Sat Jul 30 06:47:39 2022

@author: Acer
"""

import pandas as pd
import string
import json
import argparse

import spacy
from gensim import corpora

from nltk.corpus import stopwords
from gensim.models import AuthorTopicModel

from Data_Preprocessing_for_Topic_Models import case_participation
from Data_Preprocessing_for_Topic_Models import clean_text
from Data_Preprocessing_for_Topic_Models import read_cases
from Data_Preprocessing_for_Topic_Models import lemmatization
from Data_Preprocessing_for_Topic_Models import create_term_matrix

def fit_model(dictionary, dataset, author_participation, output_filename):
    model = AuthorTopicModel(corpus=dataset,
                             num_topics=flags.num_topics,
                             author2doc=author_participation, 
                             id2word=dictionary, random_state=1)
    model.save(output_filename)
    return model
 
    
def load_model(filename):
    return AuthorTopicModel.load(filename)



def output_author_vecs(model):
    author_vecs = ''
    for author in model.id2author.values():
        sorted_author_topics = sorted(model.get_author_topics(author), key=lambda x: x[1], reverse=True)
        author_vecs = author_vecs + str(author) + ': ' + str(sorted_author_topics) + '\n'
    print('author_vecs =', author_vecs)
    author_vecs_file = open("at_model_author_vecs_num_topics=" + str(flags.num_topics) + ".txt", "w")
    n = author_vecs_file.write(str(author_vecs))
    author_vecs_file.close()
    return author_vecs_file


def output_topics(model, num_topics):
    #topics = model.show_topics(num_topics=37, num_words=10)
    
    topics = ''
    for topic_id in range(num_topics):
        sorted_topic_terms = sorted(model.show_topic(topic_id, topn=10), key=lambda x: x[1], reverse=True)
        topics += str(topic_id) + ': ' + str(sorted_topic_terms) + '\n'
    print('topics =', topics)
    
    topics_file = open("at_model_topics_num_topics=" + str(flags.num_topics) + ".txt", "w")
    n = topics_file.write(str(topics))
    topics_file.close()
    return topics_file


if __name__ == "__main__":
    
  parser = argparse.ArgumentParser(description="Fit AT on court cases")
  parser.add_argument('--limit', type=int,
                      default=-1, help="Limit of number of cases")
  parser.add_argument('--author_list', type=str,
                      default="author2doc.json")
  parser.add_argument('--cases_source', type=str,
                      default="case_scraping_Aug_01_2022.csv")
  parser.add_argument('--model_save', type=str,
                      default="at_model.save")
  parser.add_argument('--num_topics', type=int, default=37)
  
  flags = parser.parse_args()

  # Comment out these lines below if you do not want to re-train the AT model, but use a saved AT model
  stop_words = stopwords.words('german')
  dictionary, cases = read_cases(flags.cases_source, limit=flags.limit)
  if flags.limit > 0:
      author_participation = case_participation(flags.author_list, flags.limit)
  else:
      author_participation = case_participation(flags.author_list, len(cases))    
  model = fit_model(dictionary, cases, author_participation, flags.model_save)
  # Comment out these two lines above if you do not want to re-train the AT model, but use a saved AT model
    
  model = load_model(flags.model_save)
  author_vecs_file = output_author_vecs(model)
  topics_file = output_topics(model, num_topics = flags.num_topics)
