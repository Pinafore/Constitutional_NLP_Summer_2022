# -*- coding: utf-8 -*-
"""
Created on Fri Jun 17 17:25:05 2022

@author: Acer
"""
#topics (i.e. dockets) = 37

#Tutorial: https://github.com/rsreetech/LDATopicModelling
# https://www.youtube.com/watch?v=nNvPvvuPnGs

import pandas as pd
import string
import json
import argparse

import spacy
from gensim import corpora

from nltk.corpus import stopwords
from gensim.models.ldamodel import LdaModel

from Data_Preprocessing_for_Topic_Models import clean_text
from Data_Preprocessing_for_Topic_Models import read_cases
from Data_Preprocessing_for_Topic_Models import lemmatization
from Data_Preprocessing_for_Topic_Models import create_term_matrix

def fit_model(dictionary, dataset, output_filename, num_topics):
    model = LdaModel(corpus=dataset,
                     num_topics=flags.num_topics,
                     id2word=dictionary, 
                     random_state=1)
    model.save(output_filename)
 
    return model


def load_model(filename):
    return LdaModel.load(filename) 


def output_topics(model, num_topics):
    topics = ''
    for topicno in range(num_topics):
        #sorted_topic_terms = sorted(model.print_topic(topicno=topicno, topn=10), key=lambda x: x[1], reverse=True)
        sorted_topic_terms = model.print_topic(topicno=topicno, topn=10)
        topics += str(topicno) + ': ' + str(sorted_topic_terms) + '\n'
    print('topics =', topics)
    
    topics_file = open("lda_model_topics.txt", "w")
    n = topics_file.write(str(topics))
    topics_file.close()
    
    return topics_file


if __name__ == "__main__":
    
  parser = argparse.ArgumentParser(description="Fit LDA on court cases")
  parser.add_argument('--limit', type=int,
                      default=-1, help="Limit of number of cases")
  parser.add_argument('--cases_source', type=str,
                      default="case_scraping_Aug_01_2022.csv")
  parser.add_argument('--model_save', type=str,
                      default="lda_model.save")
  parser.add_argument('--num_topics', type=int, default=37)
  
  flags = parser.parse_args()
  '''
  dictionary, cases = read_cases(flags.cases_source, limit=flags.limit)
  model = fit_model(dictionary, cases, flags.model_save, num_topics=flags.num_topics)
  '''
  model = load_model(flags.model_save)
  topics_file = output_topics(model, num_topics = flags.num_topics)