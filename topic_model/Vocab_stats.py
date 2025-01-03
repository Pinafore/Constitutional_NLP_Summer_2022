import json
import argparse
from collections import Counter, defaultdict
import numpy as np
import csv
import pandas as pd

def Vocab_by_freq(file_name, lower_Vocab_count_threshold=0):
    with open(file_name, 'r') as f:
        read_cases_manualATM_text_list = json.load(f)
    read_cases_manualATM_text_list_flat = [item for sublist in read_cases_manualATM_text_list for item in sublist]
    #print('read_cases_manualATM_text_list_flat:', read_cases_manualATM_text_list_flat)
    Vocab = Counter(read_cases_manualATM_text_list_flat)
    sorted_Vocab = {k: v for k, v in sorted(Vocab.items(), key=lambda item: item[1], reverse=True) if v > lower_Vocab_count_threshold}

    tf_corpus_dict = {k: v/len(read_cases_manualATM_text_list_flat) for k, v in sorted_Vocab.items()}
    print("len(read_cases_manualATM_text_list_flat):", len(read_cases_manualATM_text_list_flat))
    print("tf_corpus_dict:", tf_corpus_dict)

    with open('tf_corpus_dict_Dec04.json', 'w') as f:
      json.dump(tf_corpus_dict, f)
    with open('tf_corpus_dict_Dec04.json', 'r') as f:
      tf_corpus_dict = json.load(f)

    doc_count_dict = {word:0 for word in sorted_Vocab.keys()}
    tf_doc_max_dict = {word:0 for word in sorted_Vocab.keys()}


    for sub_list in read_cases_manualATM_text_list:
        doc_level_Vocab = Counter(sub_list)
        for word, count in doc_level_Vocab.items():
            #print('word:', word)
            #print('count:', count)
            if word in tf_doc_max_dict:
                tf_doc_max_dict[word] = max(tf_doc_max_dict[word], count/len(sub_list))
    print('tf_doc_max_dict:', tf_doc_max_dict)

    with open('tf_doc_max_dict_Dec04.json', 'w') as f:
      json.dump(tf_doc_max_dict, f)
    with open('tf_doc_max_dict_Dec04.json', 'r') as f:
      tf_doc_max_dict = json.load(f)


    for word in sorted_Vocab.keys():
        #print('word:', word)
        for sub_list in read_cases_manualATM_text_list:
            if word in sub_list:
                doc_count_dict[word] += 1
    #print('doc_count_dict:', doc_count_dict)
    idf_dict = {k: np.log(len(read_cases_manualATM_text_list)/v) for k, v in doc_count_dict.items()}
    #print('idf_dict:', idf_dict)

    with open('idf_dict_Dec04.json', 'w') as f:
      json.dump(idf_dict, f)
    with open('idf_dict_Dec04.json', 'r') as f:
      idf_dict = json.load(f)


    tf_idf_corpus_dict = {word: tf_corpus_dict[word]*idf_dict[word] for word in sorted_Vocab.keys()}
    print('tf_idf_corpus_dict:', tf_idf_corpus_dict)

    with open('tf_idf_corpus_dict_Dec04.json', 'w') as f:
      json.dump(tf_idf_corpus_dict, f)
    with open('tf_idf_corpus_dict_Dec04.json', 'r') as f:
      tf_idf_corpus_dict = json.load(f)


    tf_idf_doc_max_dict = {word: tf_doc_max_dict[word]*idf_dict[word] for word in sorted_Vocab.keys()}
    print('tf_idf_doc_max_dict:', tf_idf_doc_max_dict)

    with open('tf_idf_doc_max_dict_Dec04.json', 'w') as f:
      json.dump(tf_idf_doc_max_dict, f)
    with open('tf_idf_doc_max_dict_Dec04.json', 'r') as f:
      tf_idf_doc_max_dict = json.load(f)


    Vocab_stats_dict = {word: [tf_corpus_dict[word], tf_doc_max_dict[word], idf_dict[word], tf_idf_corpus_dict[word], tf_idf_doc_max_dict[word]] for word in sorted_Vocab.keys()}
    print('Vocab_stats_dict:', Vocab_stats_dict)

    with open('Vocab_stats_dict_Dec04.json', 'w') as f:
      json.dump(Vocab_stats_dict, f)
    with open('Vocab_stats_dict_Dec04.json', 'r') as f:
      Vocab_stats_dict = json.load(f)


    with open('sorted_Vocab_Dec04.json', 'w') as f:
        json.dump(sorted_Vocab, f)

    with open('sorted_Vocab_Dec04.json', 'r') as f:
        sorted_Vocab = json.load(f)

    with open('sorted_Vocab_Dec04.txt', "w") as f:
        n = f.write(str(sorted_Vocab))

    #print('sorted_Vocab:', sorted_Vocab)
    print('len(sorted_Vocab):', len(sorted_Vocab))



def export_stats_to_csv():
    with open('Vocab_stats_dict_Dec04.json', 'r') as f:
      Vocab_stats_dict = json.load(f)

    with open('Vocab_stats_Dec04.csv', 'w') as file:
        writer = csv.writer(file)
        writer.writerow(['word', 'corpus-level term freq', 'max doc-level term freq', 'inverse doc freq', 'corpus-level tf-idf', 'max doc-level tf-idf'])

        for word, stats_list in Vocab_stats_dict.items():
            row = [word] + stats_list
            print('row:', row)
            writer.writerow(row)

        Vocab_stats_pd = pd.read_csv('Vocab_stats_Dec04.csv')
    print("Number of lines :", len(Vocab_stats_pd))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Get the vocabulary sorted by frequency")
    parser.add_argument('--file_name', type=str, default="read_cases_manualATM_text_list_Dec04.json")
    parser.add_argument('--lower_Vocab_count_threshold', type=int, default=0)

    flags = parser.parse_args()

    Vocab_by_freq(flags.file_name, flags.lower_Vocab_count_threshold)
    export_stats_to_csv()