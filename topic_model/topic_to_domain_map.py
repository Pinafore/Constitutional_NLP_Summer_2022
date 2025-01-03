import json

topic_to_domain_dict = {0:"dm2_european", 2:"dm_press", 4:"dm2_reinstatement", 7:"dm_levies", 9:"dm_professions",
                        14:"parliament", 15:"dm_child", 18:"dm_labour", 19:"dm_healthinsurance", 20:"dm_welfare",
                        23:"dm2_asylum", 24:"dm_family", 25:"dm_tax", 26:"dm_international", 27:"dm_freedomgeneral",
                        28:"dm_socialsecurity", 30:"dm_property", 31:"dm2_european", 32:"dm_healthinsurance",
                        33:"dm2_extradition", 37:"dm_parliament", 40:"dm2_pretrial", 41:"dm_labour", 42:"dm2_prosecution",
                        45:"dm2_publicservice", 46:"dm2_detention", 47:"dm_labour", 48:"dm2_detention", 49:"dm_property"}

num_topics = 50

with open('topic_to_domain_dict_num_topics=' + str(num_topics) +  '.json', 'w') as f:
    json.dump(topic_to_domain_dict, f)

with open('topic_to_domain_dict_num_topics=' + str(num_topics) +  '.json', 'r') as f:
    topic_to_domain_dict = json.load(f)