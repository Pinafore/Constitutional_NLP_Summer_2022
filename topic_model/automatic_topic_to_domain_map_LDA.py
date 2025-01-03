import pickle
from pandas import *
import json
import argparse
from collections import defaultdict
import numpy as np

def word_match(topword, keyword):
    #Exact match regardless of word length
    topword = topword.lower()
    keyword = keyword.lower()
    if topword == keyword:
        return True
    '''
    #If both words have len <= 3, require exact match. Otherwise, just require one word being a substring of the other
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




def find_first_matched_dm(topic, topwords, topword_index, dm_keywords_dict, automatic_topic_to_domain_map, topword_index_list):
    for topword in topwords:
        topword_index += 1
        for dm, keywords in dm_keywords_dict.items():
            for keyword in keywords:
                if word_match(topword, keyword):
                    automatic_topic_to_domain_map[topic] = dm
                    topword_index_list.append(topword_index)
                    '''
                    print('topic:', topic)
                    print('dm:', dm)
                    print('topword:', topword)
                    print('keyword:', keyword)
                    print('topword_index:', topword_index)
                    print('before automatic_topic_to_domain_map:', automatic_topic_to_domain_map)
                    print('after automatic_topic_to_domain_map:', automatic_topic_to_domain_map)
                    '''

                    #See at which topword_index is there a match for the two domains of highest recall (dm_family) and precision (dm2_military)
                    if dm == 'dm_family' or dm == 'dm2_military':
                        print('topic:', topic)
                        print('topword:', topword)
                        print('keyword:', keyword)
                        print('topword_index:', topword_index)

                    return automatic_topic_to_domain_map, topword_index_list
    #still have to return sth (the same dict with no modification) if cant find a match among the 1000 top words
    return automatic_topic_to_domain_map, topword_index_list

'''
for topic, topwords in words_per_topic_dict.items():
    #automatic_topic_to_domain_map[topic] = []
    topword_index = 0
    find_first_matched_dm(topic, topwords, topword_index, dm_keywords_dict, automatic_topic_to_domain_map)

print('automatic_topic_to_domain_map:', automatic_topic_to_domain_map)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'w') as f:
    json.dump(automatic_topic_to_domain_map, f)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'r') as f:
    automatic_topic_to_domain_map = json.load(f)

with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.txt', "w") as f:
    n = f.write(str(automatic_topic_to_domain_map))
'''

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Make an automatic topic to domain map")
    parser.add_argument('--num_topics', type=int, default=50)

    flags = parser.parse_args()

    num_topics = flags.num_topics

    data_compact = read_csv("domain_keywords_both_senates.csv")
    dm_keywords_dict = {}
    #automatic_topic_to_domain_map = {}
    automatic_topic_to_domain_map = defaultdict()

    for index, row in data_compact.iterrows():
        dm = row['Docket (domain)']
        keywords = row['Keyword(s)'].split(', ')
        keyword_list = [keyword.lower() for keyword in keywords]
        dm_keywords_dict[dm] = keyword_list
        print('dm:', dm)
        print('keywords:', keywords)

    print('dm_keywords_dict:', dm_keywords_dict)

    #with open('WardNJU_words_per_topic_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    #    words_per_topic_dict = pickle.load(f)
    with open('LDA_formatted_words_per_topic_num_topics=' + str(num_topics) + '.json', 'r') as f:
        words_per_topic_dict = json.load(f)

    topword_index_list = []

    for topic, topwords in words_per_topic_dict.items():
        #automatic_topic_to_domain_map[topic] = []
        topword_index = 0
        automatic_topic_to_domain_map, topword_index_list = find_first_matched_dm(topic, topwords, topword_index, dm_keywords_dict, automatic_topic_to_domain_map, topword_index_list)

    #print('automatic_topic_to_domain_map:', automatic_topic_to_domain_map)


    print('topword_index_list:', sorted(topword_index_list))
    print('len: ', len(topword_index_list))

    topword_index_lower_quartile = np.percentile(topword_index_list, 25, method='closest_observation')
    print('topword_index_lower_quartile:', topword_index_lower_quartile)

    topword_index_med = np.percentile(topword_index_list, 50, method='closest_observation')
    print('topword_index_med:', topword_index_med)

    topword_index_upper_quartile = np.percentile(topword_index_list, 75, method='closest_observation')
    print('topword_index_upper_quartile:', topword_index_upper_quartile)

    with open('LDA_automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'w') as f:
        json.dump(automatic_topic_to_domain_map, f)

    with open('LDA_automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'r') as f:
        automatic_topic_to_domain_map = json.load(f)

    with open('LDA_automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.txt', "w") as f:
        n = f.write(str(automatic_topic_to_domain_map))