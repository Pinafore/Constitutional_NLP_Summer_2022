import pickle
from pandas import *
import json
num_topics = 50

data_compact = read_csv("domain_keywords_both_senates.csv")
dm_keywords_dict = {}
automatic_topic_to_domain_map = {}

for index, row in data_compact.iterrows():
    dm = row['Docket (domain)']
    keywords = row['Keyword(s)'].split(', ')
    keyword_list = [keyword.lower() for keyword in keywords]
    dm_keywords_dict[dm] = keyword_list
    print('dm:', dm)
    print('keywords:', keywords)

print('dm_keywords_dict:', dm_keywords_dict)


def word_match(topword, keyword):
    #If both words have len <= 3, require exact match. Otherwise, just require one word being a substring of the other
    topword = topword.lower()
    keyword = keyword.lower()
    if topword == keyword:
        return True
    '''
    if len(topword) <= 3 and len(keyword) <= 3:
        if topword == keyword:
            return True
    elif len(topword) <= 3 and len(keyword) > 3:
        if topword in keyword:
            return True
    elif len(topword) > 3 and len(keyword) <= 3:
        if keyword in topword:
            return True
    else:
        if (keyword in topword) or (topword in keyword):
            return True
    
    return False
    '''

'''
#Unit tests for the word_match function
assert word_match('Ai', 'ai')
assert not word_match('octopus', 'october')
assert word_match('octopus', 'oct')
assert word_match('oct', 'october')
assert word_match('love', 'lovely')
'''

with open('WardNJU_words_per_topic_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    words_per_topic_dict = pickle.load(f)


def find_first_matched_dm(topic, topwords, topword_index):
    for topword in topwords:
        topword_index += 1
        for dm, keywords in dm_keywords_dict.items():
            for keyword in keywords:
                if word_match(topword, keyword):
                    print('topword:', topword)
                    print('keyword:', keyword)
                    print('topword_index:', topword_index)
                    automatic_topic_to_domain_map[topic] = dm
                    return 1


for topic, topwords in words_per_topic_dict.items():
    #automatic_topic_to_domain_map[topic] = []
    topword_index = 0
    find_first_matched_dm(topic, topwords, topword_index)
    '''
    for topword in topwords:
        topword_index += 1
        for dm, keywords in dm_keywords_dict.items():
            for keyword in keywords:
                if word_match(topword, keyword):
                    print('topword:', topword)
                    print('keyword:', keyword)
                    print('topword_index:', topword_index)
                    automatic_topic_to_domain_map[topic].append(dm)
                    continue
                    continue
                    continue
                    continue
                    continue #move on to the next topic
    '''
print('automatic_topic_to_domain_map:', automatic_topic_to_domain_map)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'w') as f:
    json.dump(automatic_topic_to_domain_map, f)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'r') as f:
    automatic_topic_to_domain_map = json.load(f)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.txt', "w") as f:
    n = f.write(str(automatic_topic_to_domain_map))


            #for keywords with len <= 3, only accept exact match
            #for keywords with len > 3, check if keyword is a substring in any of the top words