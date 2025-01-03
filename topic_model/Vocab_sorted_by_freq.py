import json
import argparse
from collections import Counter

def Vocab_by_freq(file_name):
    with open(file_name, 'r') as f:
        read_cases_manualATM_text_list = json.load(f)
    read_cases_manualATM_text_list_flat = [item for sublist in read_cases_manualATM_text_list for item in sublist]
    #print('read_cases_manualATM_text_list_flat:', read_cases_manualATM_text_list_flat)
    Vocab = Counter(read_cases_manualATM_text_list_flat)
    sorted_Vocab = {k: v for k, v in sorted(Vocab.items(), key=lambda item: item[1], reverse=True)}


    with open('sorted_Vocab.json', 'w') as f:
        json.dump(sorted_Vocab, f)

    with open('sorted_Vocab.json', 'r') as f:
        sorted_Vocab = json.load(f)

    print('sorted_Vocab:', sorted_Vocab)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Get the vocabulary sorted by frequency")
    parser.add_argument('--file_name', type=str, default='read_cases_manualATM_text_list.json')
    flags = parser.parse_args()

    Vocab_by_freq(flags.file_name)