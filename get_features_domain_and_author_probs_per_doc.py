import json
import pickle
from collections import defaultdict
import numpy as np
import pandas as pd


num_topics = 50
topN = num_topics
def invert_one_to_one(my_map):
    inv_map = defaultdict(list)
    for node, neighbor in my_map.items():
        #print('node:', node)
        #print('neighbors:', neighbors)
        #for neighbor in neighbors:
        #    print('neighbor:', neighbor)
        inv_map[neighbor].append(node)
    return inv_map


with open('WardNJU_topics_per_doc_topN=' + str(topN) + '_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    topics_prob_per_doc_all = pickle.load(f)

doc_num = len(topics_prob_per_doc_all)
print('doc_num:', doc_num)

additional_features_dict = {'uid':range(doc_num)}
#additional_domain_features_dict = {'uid':range(doc_num)}
#additional_author_features_dict = {}


with open('automatic_topic_to_domain_map_num_topics=' + str(num_topics) + '.json', 'r') as f:
    automatic_topic_to_domain_map = json.load(f)

print('automatic_topic_to_domain_map:', automatic_topic_to_domain_map)

domain_to_topic_map = invert_one_to_one(automatic_topic_to_domain_map)



#Add per-doc domain probability features
for domain in domain_to_topic_map:
    col_name = domain + '_prob'
    closest_topics = domain_to_topic_map[domain]
    #print('domain:', domain)
    domain_prob_list = []
    #print('closest_topics:', closest_topics)
    for doc_id in range(doc_num):
        #Get the probability of the closest topic to this domain
        topics_prob_for_doc_id = topics_prob_per_doc_all[doc_id]
        topics_for_doc_id = topics_prob_for_doc_id.keys()
        #print('closest_topics:', closest_topics)
        #print('topics_prob_for_doc_id:', topics_prob_for_doc_id)
        #print('type(topics_prob_for_doc_id):', type(topics_prob_for_doc_id))
        intersection_topics = list(set(closest_topics) & set(topics_for_doc_id))
        #print('intersection_topics:', intersection_topics)
        if len(intersection_topics) > 0:
            probs = [topics_prob_for_doc_id[intersection_topic] for intersection_topic in intersection_topics]
            #print('probs:', probs)
            avg_prob = np.mean(probs)
            #print('avg_prob:', avg_prob)
        else:
            avg_prob = 0
        domain_prob_list.append(avg_prob)

    additional_features_dict[col_name] = domain_prob_list



#This portion augments the per-doc distribution of authors' probabilities

#Get per-doc distribution of authors
with open('WardNJU_authors_per_doc_topN=8_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    authors_prob_per_doc_all = pickle.load(f)
doc_num = len(authors_prob_per_doc_all)
print('doc_num:', doc_num)
#Sample: {0: {'winter': 0.42, 'limbach': 0.32, 'kruis': 0.25}, 1: {'jaeger': 0.35, 'steiner': 0.33, 'kuehling': 0.32},...}

unique_author_list = []
for author_prob_dict_per_doc in authors_prob_per_doc_all.values():
    authors = list(author_prob_dict_per_doc.keys())
    unique_author_list = list(np.unique(unique_author_list + authors))

print('unique_author_list:', unique_author_list)

#Add per-doc domain probability features
for author in unique_author_list:
    col_name = author + '_prob'
    author_prob_list = []

    for doc_id in range(doc_num):
        authors_prob_for_doc_id = authors_prob_per_doc_all[doc_id]
        authors_for_doc_id  = authors_prob_for_doc_id.keys()
        if author in authors_for_doc_id:
            prob = authors_prob_for_doc_id[author]
        else:
            prob = 0
        author_prob_list.append(prob)

    additional_features_dict[col_name] = author_prob_list


with open('WardNJU_authors_per_doc_topN=1_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    top_author_prob_per_doc = pickle.load(f)
print('len top_author_prob_per_doc:', len(top_author_prob_per_doc))

top_author_list = []
top_prob_list = []

for doc_id in top_author_prob_per_doc.keys():
    top_author_prob_for_doc_id = top_author_prob_per_doc[doc_id]

    #top_author_list += [str(top_author_prob_for_doc_id.keys())]
    #top_prob_list += [top_author_prob_for_doc_id.values()]

    
    if len(top_author_prob_for_doc_id.keys()) > 0:
        top_author_list += top_author_prob_for_doc_id.keys()
    else:
        top_author_list += [np.nan]
    
    if len(top_author_prob_for_doc_id.values()) > 0:
        top_prob_list += top_author_prob_for_doc_id.values()
    else:
        top_prob_list += [np.nan]


#print('top_author_list:', top_author_list)
#print('top_prob_list:', top_prob_list)
print('len top_author_list:', len(top_author_list))
print('len top_prob_list:', len(top_prob_list))

additional_features_dict['top_author'] = top_author_list
additional_features_dict['top_author_prob'] = top_prob_list



#additional_features_dict = additional_domain_features_dict + additional_author_features_dict

additional_features = additional_features_dict.keys()
print('additional_features:', additional_features)

df_additional_features = pd.DataFrame(additional_features_dict)

df_additional_features.to_csv('additional_features.csv', index=False)

df_additional_features = pd.read_csv('additional_features.csv', low_memory=False)

df_noNaN = pd.read_csv('bverfg230107_with_break_noNaN.csv', low_memory=False)

df = df_noNaN.merge(df_additional_features, on='uid')

df.to_csv('bverfg230107_with_break_noNaN_w_domain_and_topic_prob_features.csv')


#additional_features: dict_keys(['uid', 'dm_environmental_prob', 'dm_tax_prob', 'dm_property_prob', 'dm_labour_prob', 'dm2_crim_prob', 'dm2_publicservice_prob', 'dm_family_prob', 'dm_corporations_prob', 'dm_socialsecurity_prob', 'dm2_foreigner_prob', 'dm_manifestations_prob', 'dm_levies_prob', 'dm2_municipalities_prob', 'dm_professions_prob', 'dm2_extradition_prob', 'dm2_parliament_prob', 'dm2_prosecution_prob', 'dm_freedomgeneral_prob', 'dm_speech_prob', 'dm2_detention_prob', 'dm2_pretrial_prob',
#'baer_prob', 'britz_prob', 'bross_prob', 'brossss_prob', 'bryde_prob', 'christ_prob', 'difabio_prob', 'eichberger_prob', 'fkirchhof_prob', 'gaier_prob', 'gerhard_prob', 'gerhardt_prob', 'grasshof_prob', 'grimm_prob', 'haas_prob', 'haertel_prob', 'harbarth_prob', 'hassemer_prob', 'hermanns_prob', 'hoemig_prob', 'hoffmannriem_prob', 'hohmanndennhardt_prob', 'huber_prob', 'jaeger_prob', 'jentsch_prob', 'kessalwulf_prob', 'kessalwulff_prob', 'koenig_prob', 'kruis_prob', 'kuehling_prob', 'landau_prob', 'langenfeld_prob', 'limbach_prob', 'luebbewolff_prob', 'maidowski_prob', 'masing_prob', 'mellinghoff_prob', 'osterloh_prob', 'ott_prob', 'papier_prob', 'paulus_prob', 'pkirchhof_prob', 'pmueller_prob', 'radtke_prob', 'schluckebier_prob', 'seibert_prob', 'seidl_prob', 'sommer_prob', 'steiner_prob', 'vosskuhle_prob', 'wallrabenstein_prob', 'winter_prob', 'wolff_prob',
# 'top_author', 'top_author_prob'])
