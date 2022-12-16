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
                     num_topics=num_topics,
                     id2word=dictionary,
                     passes=100,
                     random_state=1)
    model.save(output_filename)
 
    return model


def load_model(filename):
    return LdaModel.load(filename) 


def output_topics(model, num_topics):
    '''
    topics = ''
    for topicno in range(num_topics):
        #sorted_topic_terms = sorted(model.print_topic(topicno=topicno, topn=10), key=lambda x: x[1], reverse=True)
        sorted_topic_terms = model.print_topic(topicno=topicno, topn=1000)
        topics += str(topicno) + ': ' + str(sorted_topic_terms) + '\n'
    print('topics =', topics)
    
    topics_file = open("lda_model_topics_num_topics=" + str(num_topics) + ".txt", "w")
    n = topics_file.write(str(topics))
    topics_file.close()
    return topics_file
    '''

    words_per_topic_dict = {}
    for topicno in range(num_topics):
        sorted_topic_terms = model.print_topic(topicno=topicno, topn=1000)
        words_per_topic_dict[topicno] = sorted_topic_terms

    with open('LDA_words_per_topic_num_topics=' + str(num_topics) + '.json', 'wb') as f:
        pickle.dump(words_per_topic_dict, f)
    with open('LDA_words_per_topic_num_topics=' + str(num_topics) + '.json', 'rb') as f:
        words_per_topic_dict = pickle.load(f)
    return words_per_topic_dict


def output_doc_topic_distribution(model, doc_term_matrix, num_topics):
    all_topics = model.get_document_topics(doc_term_matrix)#, minimum_probability=0.1)
    #topic_distribution_per_doc_file = open("lda_model_topics_per_doc_num_topics=" + str(num_topics) + ".txt", "w")
    topics_per_doc_dict = {}
    case_id = 0
    for doc_topics in all_topics:
        case_id += 1

        doc_topics = sorted(doc_topics, key=lambda x: x[1], reverse=True)
        if len(doc_topics) > 3:
            doc_topics = doc_topics[:3] #only select top 3 topics per doc
        print('Document ' + str(case_id) + ' has most likely topics: ' + str(doc_topics) + '\n')
        topics_per_doc_dict[case_id] = doc_topics

    with open('LDA_topics_per_doc_num_topics=' + str(num_topics) + '.json', 'wb') as f:
        pickle.dump(topics_per_doc_dict, f)
    with open('LDA_topics_per_doc_num_topics=' + str(num_topics) + '.json', 'rb') as f:
        topics_per_doc_dict = pickle.load(f)

    return topics_per_doc_dict

        #n = topic_distribution_per_doc_file.write(
        #    'Document ' + str(case_id) + ' has most likely topics: ' + str(doc_topics) + '\n')
    #topic_distribution_per_doc_file.close()
    

    #return topic_distribution_per_doc_file

if __name__ == "__main__":
    
  parser = argparse.ArgumentParser(description="Fit LDA on court cases")
  parser.add_argument('--limit', type=int,
                      default=-1, help="Limit of number of cases")
  parser.add_argument('--cases_source', type=str,
                      default="case_scraping_01_1998_to_07_2022_noNaN.csv")
  parser.add_argument('--num_topics', type=int, default=50)
  
  flags = parser.parse_args()
  
  #dictionary, cases = read_cases(flags.cases_source, limit=flags.limit)

  # Save and Load
  import pickle

  '''
  with open('read_cases_dictionary.json', 'wb') as f:
      pickle.dump(dictionary, f)
  with open('read_cases_cases.json', 'wb') as f:
      pickle.dump(cases, f)
  '''
  with open('read_cases_dictionary.json', 'rb') as f:
      dictionary = pickle.load(f)
  with open('read_cases_cases.json', 'rb') as f:
      cases = pickle.load(f)

  #Save cases (corpora)
  '''
  corpora_file = open("corpora.txt", "w")
  n = corpora_file.write(str(cases))
  corpora_file.close()
  '''

  model = fit_model(dictionary, cases, output_filename="lda_model_num_topics=" + str(flags.num_topics) + ".save", num_topics=flags.num_topics)
  
  model = load_model(filename="lda_model_num_topics=" + str(flags.num_topics) + ".save")
  
  words_per_topic_dict = output_topics(model, num_topics = flags.num_topics)
  topics_per_doc_dict =  output_doc_topic_distribution(model, doc_term_matrix=cases, num_topics = flags.num_topics)