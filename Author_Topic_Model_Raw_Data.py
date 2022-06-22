# -*- coding: utf-8 -*-
"""
Created on Sun Jun 12 21:35:18 2022

@author: Acer
"""
#Documentation: https://radimrehurek.com/gensim/models/atmodel.html?fbclid=IwAR1WbQOM-vCFzfEiwqUOrXISNGZJIeppILYiqSJEUd2DvNkuHKOV6dJISgI
#Tutorial: https://nbviewer.org/github/rare-technologies/gensim/blob/develop/docs/notebooks/atmodel_tutorial.ipynb

#Make a dictionary author2doc of which cases (documents) each justice participates in
import numpy as np
import pandas as pd
col_list = ["bverfg_id", "participating_judges"]
df = pd.read_csv("20200929_bverfg_cases.csv", usecols=col_list)
'''
authors_no_curly_brackets = [authors[1:-2] for authors in df["participating_judges"]]
authors_no_und = [authors.replace( ' und', '') for authors in authors_no_curly_brackets] #take out ' und'
authors_no_space = [authors.replace( ' ', '') for authors in authors_no_und] #take out empty space
author_split_list = [authors.split(",") for authors in authors_no_space]
#author_split_list = [authors.split(",") for authors in authors_no_curly_brackets]

#author_split_list = [str(authors).split(" ") for authors in author_split_list]

flat_author_split_list = [element for sublist in author_split_list for element in sublist]
#print(author_split_list)
unique_author = np.unique(flat_author_split_list, return_counts=False)
unique_author_df = pd.DataFrame(unique_author,columns=['unique_author'])
unique_author_filter_len = unique_author_df[unique_author_df['unique_author'].str.len()<20]
unique_author_filter_len = np.array(unique_author_filter_len)

#print(unique_author_filter_len)
#print(unique_author_filter_len.shape)

print('authors_no_curly_brackets.shape =', np.array(authors_no_curly_brackets).shape)
print('len(authors_no_curly_brackets) =', np.array(len(authors_no_curly_brackets)))
author2doc = {} #initialize dictionary
for key in unique_author_filter_len:
    value = []

    for idx in range(len(author_split_list)):
        print('key: ', key)
        #if str(key) in str(authors_no_curly_brackets[idx]):
        if key in author_split_list[idx]:
        #if big_str.find(key) == True: #check if key is sub-string of author list of each sample (ruling)
            value.append(idx)
    print('value=', value)  
    
    #value = [idx for idx in range(len(authors_no_curly_brackets)) if str(key) in str(authors_no_curly_brackets[idx])]
    author2doc[str(key)] = value
    
#print('author2doc =', author2doc)

import json

a_file = open("author2doc.json", "w")
json.dump(author2doc, a_file)
a_file.close()
'''
a_file = open("author2doc.json", "r")
author2doc = a_file.read()
import json
author2doc = json.loads(author2doc) #convert str to dict
#print('author2doc =', author2doc)
a_file.close()

#Construct corpus in BoW format
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

#print('Number of rulings =', len(df_full_text))

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

#print('after clean_text: df_full_text=', df_full_text)

from nltk.corpus import stopwords
stop_words = stopwords.words('german')
# function to remove stopwords
def remove_stopwords(text):
    textArr = text.split(' ')
    rem_text = " ".join([i for i in textArr if i not in stop_words])
    return rem_text

#df_sampled = df_full_text.groupby('bverfg_id').apply(lambda x: x.sample(frac=0.1, replace=True)).reset_index(drop = True)
df_sampled = df_full_text
print('df_sampled=', df_sampled)

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

dictionary = corpora.Dictionary(tokenized_rulings)
doc_term_matrix = [dictionary.doc2bow(rul) for rul in tokenized_rulings]



#Start with Author-Topic model
from gensim.models import AuthorTopicModel
#from gensim.corpora import mmcorpus
#from gensim.test.utils import common_dictionary, datapath, temporary_file

#print('doc_term_matrix.shape =', np.array(doc_term_matrix).shape)
#print('author2doc.shape =', np.array(author2doc).shape)
#print('dictionary.id2token =', dictionary.id2token)
#print('dictionary.id2token.shape =', np.array(dictionary.id2token).shape)

#print('Number of authors: %d' % len(author2doc))
#print('Number of unique tokens: %d' % len(dictionary))
#print('Number of documents: %d' % len(doc_term_matrix))

'''
with temporary_file("serialized") as s_path:
    model = AuthorTopicModel(
        corpus=doc_term_matrix, author2doc=author2doc, id2word=dictionary.id2token, num_topics=37,
        serialized=True, serialization_path=s_path)
    #model.update(doc_term_matrix, author2doc)  # update the author-topic model with additional documents
'''

#model = AuthorTopicModel(corpus=doc_term_matrix, num_topics=37, id2word=dictionary.id2token,
#                author2doc=author2doc, passes=1, eval_every=0, iterations=1, random_state=1)

model = AuthorTopicModel(corpus=doc_term_matrix, num_topics=37, author2doc=author2doc, chunksize=200, passes=1, eval_every=0, iterations=1, random_state=1)

model.save('Author_Topic_model.atmodel')
model = AuthorTopicModel.load('Author_Topic_model.atmodel')

# construct vectors for authors
author_vecs = [model.get_author_topics(author) for author in model.id2author.values()]
print('author_vecs =', author_vecs)
author_vecs_file = open("Author_Topic_Model_author_vecs.txt", "w")
n = author_vecs_file.write(str(author_vecs))
author_vecs_file.close()

'''
topics = get_topic_terms(topicid, topn=10)
topics = lda_model.print_topics()
topics_file = open("Author_Topic_Model_topics.txt", "w")
n = topics_file.write(str(topics))
topics_file.close()
'''