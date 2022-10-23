"""
Time: Sat Oct 22

@author: Jiannan, Tin
"""

import json
import re
import string
from collections import defaultdict
import itertools

# Remove special characters
def remove_punctuation(text):
    text = ''.join([c for c in text if c not in string.punctuation])
    return text
   
def clean_author2doc(file_uncleaned):
    # input: uncleaned author2doc json file
    # output: cleaned author2doc json file

    # open JSON file
    f = open(file_uncleaned)

    # load json file, a dictionary
    data = json.load(f)

    # for key_token in data.keys():
    data_keys = list(data.keys())
    data_keys_cleaned = [remove_punctuation(i) for i in data_keys]
    # data_keys_cleaned_unique = [*set(data_keys_cleaned)]

    # create a dictionary of frequency 
    dict_cleaned  = defaultdict(list)
    for i,item in enumerate(data_keys_cleaned):
        dict_cleaned[item].extend([i])

    # create a dictionary of final output
    json_cleaned_target = defaultdict(list)
    for keys in dict_cleaned.keys():
        json_cleaned_target[keys] = list(itertools.chain.from_iterable([data.get(list(data)[i]) for i in dict_cleaned[keys]]))

    # further adjustments
    # drop keys that don't make sense
    drop_keys = ['', 'us','Mitwirkung','gerichts','unter']
    for key in drop_keys:
        json_cleaned_target.pop(key, None)

    # extend the right keys
    json_cleaned_target['Broß'].extend(json_cleaned_target['Bro'])
    json_cleaned_target['Gerhardt'].extend(json_cleaned_target['Gerhard'])
    json_cleaned_target['Hassemer'].extend(json_cleaned_target['Hasseme'])
    json_cleaned_target['Henschel'].extend(json_cleaned_target['Hentschel'])
    json_cleaned_target['Hermanns'].extend(json_cleaned_target['Herrmanns'])
    json_cleaned_target['Hömig'].extend(json_cleaned_target['Hmig'])
    json_cleaned_target['HohmannDennhard'].extend(json_cleaned_target['HohmannDennhardt'])
    json_cleaned_target['Jäger'].extend(json_cleaned_target['Jaeger'])
    json_cleaned_target['KessalWulf'].extend(json_cleaned_target['KessalWulff'])
    json_cleaned_target['Kühling'].extend(json_cleaned_target['Khling'])
    json_cleaned_target['LübbeWolff'].extend(json_cleaned_target['LübbeWoff'])
    json_cleaned_target['Voßkuhle'].extend(json_cleaned_target['Vosskuhle'])
    json_cleaned_target['Wallrabenstein'].extend(json_cleaned_target['Wallrabensein'])

    drop_keys_alt = ['Bro','Gerhard','Hasseme','Hentschel','Herrmanns','Hmig','HohmannDennhardt', \
                    'Jaeger','KessalWulff','Khling','LübbeWoff','Vosskuhle','Wallrabensein']
    for key in drop_keys_alt:
        json_cleaned_target.pop(key, None)
    
    # rename one key
    json_cleaned_target['Leusser'] = json_cleaned_target.pop('Leuser', None)

    #print(sorted(json_cleaned_target))
    return json_cleaned_target



if __name__ == "__main__":
    json_cleaned = clean_author2doc("author2doc.json")
    with open('clean_author2doc.json', 'w') as f:
        json.dump(json_cleaned, f)





    
