# -*- coding: utf-8 -*-
"""
Created on Mon Jul 18 14:03:33 2022

@author: Acer
"""

import numpy as np
import pandas as pd
col_list = ["bverfg_id_forward", "participating_judges"]
df = pd.read_csv("case_scraping_01_1998_to_07_2022.csv", usecols=col_list)

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

a_file = open("author2doc_01_1998_to_07_2022.json", "w")
json.dump(author2doc, a_file)
a_file.close()