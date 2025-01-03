import pandas as pd
from collections import defaultdict
import numpy as np
import pickle
import json
def def_value():
    return "Not Present"

#Define a function to invert a dictionary (keys become values, and v.v.)
def invert(my_map):
    inv_map = defaultdict(list)
    for node, neighbours in my_map.items():
        for neighbour in neighbours:
            inv_map[neighbour].append(node)
    return inv_map

domain2author = defaultdict(def_value)

def add_domain2author(file_name):
    df = pd.read_csv(file_name, header=None)
    columns = list(df)[4:]


    for i in columns:
        authors = list(set(df[i][2:]))
        print('authors:', authors)
        #the nan elements have type(nan) = float
        authors = [x for x in authors if type(x)==str]#np.isnan(x) == False]
        # for the German portion of the topic name, just take up to 30 characters
        domain = df[i][0][:min(len(df[i][0]), 30)] + " i.e. " + str(df[i][1])
        if domain in domain2author.keys():
            domain2author[domain] += authors
            domain2author[domain] = list(set(domain2author[domain]))
        else:
            domain2author[domain] = authors

add_domain2author("SenatI.csv")
add_domain2author("SenatII.csv")
#print('domain2author:', domain2author)

author2domain = invert(domain2author)
#print('author2domain:', author2domain)

#with open('clean_author2doc_01_1998_to_07_2022.json', 'rb') as f:
with open('clean_author2doc_01_1998_to_07_2022.json', 'rb') as f:
    author2doc = json.load(f)

doc2author = invert(author2doc)
#print('doc2author:', doc2author)


doc2domain = defaultdict(def_value)
for doc in doc2author:
    domains = []
    for author in doc2author[doc]:
        domains += author2domain[author]
        print('domain list:', domains)
    #Take the domains corresponding to each doc as the union of the domains of the authors of that document
    domains = set(domains)
    print('domain set:', domains)
    doc2domain[doc] = domains

with open('doc2domain.json', 'wb') as f:
    pickle.dump(doc2domain, f)

with open('doc2domain.json', 'rb') as f:
    doc2domain = pickle.load(f)
print('doc2domain:', doc2domain)

domain2doc = invert(doc2domain)

with open('domain2doc.json', 'wb') as f:
    pickle.dump(domain2doc, f)

with open('domain2doc.json', 'rb') as f:
    domain2doc = pickle.load(f)
print('domain2doc:', domain2doc)