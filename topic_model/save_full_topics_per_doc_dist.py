import json
import pickle
import numpy as np
from collections import Counter

with open('read_cases_manualATM_text_list_bverfg230107.json', 'r') as f:
    read_cases_manualATM_text_list = json.load(f)

num_topics = 200
docs_count = len(read_cases_manualATM_text_list)
print('docs_count:', docs_count)

with open('WardNJU_Z_assignment_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    Z_assignment = pickle.load(f)

topN = num_topics

def print_topics_per_doc(topN=topN):
    topics_prob_per_doc_all = {}  # dict of dict
    for m in range(docs_count):
        z_doc = Z_assignment[m]
        # print('z_doc:', z_doc)
        z_keys, z_counts = np.array(list(Counter(z_doc).keys())), np.array(list(Counter(z_doc).values()))
        z_probs = np.array([round(z_count / sum(z_counts), 2) for z_count in z_counts])
        # print('z_keys:', z_keys)
        # print('z_counts:', z_counts)
        # print('z_probs:', z_probs)
        #if len(z_counts) > topN:
        top_indices = z_counts.argsort()[::-1][:topN]
        z_keys = z_keys[top_indices]
        z_probs = z_probs[top_indices]
            # print('top z_keys:', z_keys)
            # print('top z_probs:', z_probs)
        topic_prob_per_doc_dict = {}
        for idx in range(len(z_keys)):
            topic_prob_per_doc_dict[str(z_keys[idx])] = z_probs[idx]
        # print('topic_prob_per_doc_dict:', topic_prob_per_doc_dict)
        # print('Document {} has most likely topics:{}'.format(m, topic_prob_per_doc_dict))
        topics_prob_per_doc_all[m] = topic_prob_per_doc_dict
    return topics_prob_per_doc_all


topics_prob_per_doc_all = print_topics_per_doc(topN=topN)

with open('WardNJU_topics_per_doc_topN=' + str(topN) + '_num_topics=' + str(num_topics) + '.json', 'wb') as f:
    pickle.dump(topics_prob_per_doc_all, f)

with open('WardNJU_topics_per_doc_topN=' + str(topN) + '_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    topics_prob_per_doc_all = pickle.load(f)

with open('WardNJU_topics_per_doc_topN=' + str(topN) + '_num_topics=' + str(num_topics) + '.txt', "w") as f:
    n = f.write(str(topics_prob_per_doc_all))

print('topics_prob_per_doc_all:', topics_prob_per_doc_all)