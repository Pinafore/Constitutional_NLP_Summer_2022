from collections import defaultdict
import json
import pickle
import argparse
import pandas as pd

sample_dict = {0: {'40': 0.34, '21': 0.17, '34': 0.12}, 1: {'47': 0.38, '49': 0.16, '32': 0.11}, 2: {'47': 0.22, '28': 0.2, '32': 0.1}}
def invert(dict_of_dict, topN=10):
    inv_dict_of_dict = defaultdict(dict)
    for doc, topic_prob_dict in dict_of_dict.items():
        for topic, prob in topic_prob_dict.items():
            inv_dict_of_dict[topic][doc] = prob
    #Sort the smaller dict associated to each topic by probability of each doc

    for topic in inv_dict_of_dict.keys():
        inv_dict_of_dict[topic] = {k: v for k, v in sorted(inv_dict_of_dict[topic].items(), key=lambda item: item[1], reverse=True)[:topN]}
    #Sort big dict by key (topic) for readability
    sorted_inv_dict_of_dict = {k: v for k, v in sorted(inv_dict_of_dict.items(), key=lambda item: int(item[0]))}
    print('keys:', sorted_inv_dict_of_dict.keys())
    return sorted_inv_dict_of_dict


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Implement AT Model with Gibbs")
    parser.add_argument('--num_topics', type=int, default=50)
    parser.add_argument('--file_name', type=str, default="case_scraping_01_1998_to_07_2022_noNaN.csv")

    flags = parser.parse_args()


    sample_inv_dict = invert(sample_dict)
    #print('sample_inv_dict:', sample_inv_dict)

    with open('WardNJU_topics_per_doc_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        topics_prob_per_doc_all = pickle.load(f)

    docs_prob_per_topic = invert(topics_prob_per_doc_all)
    print("docs_prob_per_topic:", docs_prob_per_topic)

    #sample of docs_prob_per_topic: {'0': {3427: 0.33, 295: 0.2, 1688: 0.18, 7302: 0.14, 829: 0.13, 1351: 0.12, 3666: 0.11, 1977: 0.1, 5035: 0.1, 6015: 0.1}, '1': {3529: 0.44, 5779: 0.25, 5778: 0.24, 5390: 0.23, 3738: 0.22, 5226: 0.22, 5593: 0.22, 3747: 0.2, 4510: 0.19, 4852: 0.19}}
    content_per_topic = defaultdict(list)
    df = pd.read_csv(flags.file_name, usecols=["date_and_first_docket", "short_description"])

    with open("read_cases_manualATM_text_list.json", 'r') as f:
        read_cases_manualATM_text_list = json.load(f)

    with open('topic_to_domain_dict_num_topics=' + str(flags.num_topics) + '.json', 'r') as f:
        topic_to_domain_dict = json.load(f)

    with open('WardNJU_words_per_topic_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        topics = pickle.load(f)


    with open('top_docs_per_topic_num_topics= ' + str(flags.num_topics) + '.txt', "w") as f:

        for topic, doc_prob_dict in docs_prob_per_topic.items():
            if topic in topic_to_domain_dict.keys():
                domain = topic_to_domain_dict[topic]
            else:
                domain = 'None'
            n = f.write('TOPIC ' + str(topic) + ' with corresponding domain: ' + domain + ' and top 10 words: '
                        + str(topics[int(topic)]) + ' have top documents:')
            n = f.write('\n \n')
            for doc_id in doc_prob_dict.keys():
                read_cases_manualATM_text_list_doc = read_cases_manualATM_text_list[doc_id]
                read_cases_manualATM_text_list_doc_first_5_words = read_cases_manualATM_text_list_doc[:5]
                content = str(df['date_and_first_docket'].loc[int(doc_id)]) + " => short_description: " \
                          + str(df['short_description'].loc[int(doc_id)] + " => up to first 5 preprocessed words: "
                                + str(read_cases_manualATM_text_list_doc_first_5_words))
                n = f.write(content)
                n = f.write('\n \n \n')
                content_per_topic[topic].append(content)
                #print("date_and_first_dockets_per_topic:", date_and_first_dockets_per_topic)
            n = f.write('\n')
        print("content_per_topic:", content_per_topic)
    '''
    with open('top_docs_per_topic_num_topics= ' + str(flags.num_topics) + '.txt', "w") as f:
        n = f.write(str(content_per_topic))
        n = f.write('\n')
        n = f.write('done')
    '''