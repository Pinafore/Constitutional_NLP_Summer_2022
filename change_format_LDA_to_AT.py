import pickle
import re
import json
#inputstring = ' some strings are present in between "geeks" "for" "geeks" '

#print(re.findall('"([^"]*)"', inputstring))
num_topics=200

with open('LDA_words_per_topic_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    words_per_topic_dict = pickle.load(f)

#Use regular expression to extract all words in double quotation " " from a long string (value corresponding to a topic)
words_per_topic_dict = {int(k):re.findall('"([^"]*)"', v) for k, v in words_per_topic_dict.items()}
print('words_per_topic_dict:', words_per_topic_dict)

with open('LDA_formatted_words_per_topic_num_topics=' + str(num_topics) + '.json', 'w') as f:
    json.dump(words_per_topic_dict, f)

words_per_topic_dict_top10 = {int(k):v[:10] for k, v in words_per_topic_dict.items()}
print('words_per_topic_dict_top10:', words_per_topic_dict_top10)

with open('LDA_formatted_top10_words_per_topic_num_topics=' + str(num_topics) + '.json', 'w') as f:
    json.dump(words_per_topic_dict_top10, f)

'''
with open('LDA_topics_per_doc_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    topics_per_doc_dict = pickle.load(f)

topics_per_doc_dict = {int(k):[tup[0] for tup in v] for k, v in topics_per_doc_dict.items()}
print('topics_per_doc_dict:', topics_per_doc_dict)

with open('LDA_formatted_topics_per_doc_num_topics=' + str(num_topics) + '.json', 'w') as f:
    json.dump(topics_per_doc_dict, f)
    '''
