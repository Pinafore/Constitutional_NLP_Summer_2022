import json
import pandas as pd

with open('authors_per_doc_lol_bverfg230107.json', 'r') as f:
    authors_per_doc_lol = json.load(f)

print('authors_per_doc_lol:', authors_per_doc_lol)

uid_and_clean_judges_dict = {'uid': range(len(authors_per_doc_lol)), 'clean_judges':authors_per_doc_lol}

# Create DataFrame
df_with_clean_judges = pd.DataFrame(uid_and_clean_judges_dict)
df_with_additional_features = pd.read_csv('bverfg230107_with_break_noNaN_w_domain_and_topic_prob_features.csv', low_memory=False)
df = df_with_additional_features.merge(df_with_clean_judges, on='uid')

df.to_csv('bverfg230107_with_break_noNaN_w_additional_features_and_clean_judges.csv')

