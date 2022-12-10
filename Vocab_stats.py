import json
import argparse
from collections import Counter, defaultdict
import numpy as np
def Vocab_by_freq(file_name):
    with open(file_name, 'r') as f:
        read_cases_manualATM_text_list = json.load(f)
    read_cases_manualATM_text_list_flat = [item for sublist in read_cases_manualATM_text_list for item in sublist]
    #print('read_cases_manualATM_text_list_flat:', read_cases_manualATM_text_list_flat)
    Vocab = Counter(read_cases_manualATM_text_list_flat)
    sorted_Vocab = {k: v for k, v in sorted(Vocab.items(), key=lambda item: item[1], reverse=True) if v > 3}

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

'''
#with open('read_cases_manualATM_text_list_Dec04.json', 'r') as f:
with open('read_cases_manualATM_text_list_Dec04.json', 'r') as f:
    text_list = json.load(f)

print("len(text_list):", len(text_list))

#Initialize a Vocabulary dictionary with each preprocessed word as a key and
#its corresponding corpus-level TF, DF, corpus-level TF-IDF, max doc-level TF,
#max doc-level TF-IDF
Vocacb_dict = {}
'''


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Get the vocabulary sorted by frequency")
    parser.add_argument('--file_name', type=str, default="read_cases_manualATM_text_list_Dec04.json")
    flags = parser.parse_args()

    Vocab_by_freq(flags.file_name)