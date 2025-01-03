##### BVerfG
##### Referee: Prepare for / from GPT
##### 240129

##### HOUSEKEEPING ----
##### clean
import os
import glob
import pandas as pd
import numpy as np
import re
from nltk.tokenize import word_tokenize
import matplotlib.pyplot as plt
import seaborn as sns

##### set working directory
os.chdir("/Users/amao/git/Constitutional_NLP_Summer_2022/2024 Referee")

##### EXTRACT DOMAIN FROM GPT RESPONSE ----
#### extract information from GPT ----
### extract domain number from GPT response ----
### prepare files
directory = '/Users/amao/git/Constitutional_NLP_Summer_2022/venv/senate_1/responses'
write_path = '/Users/amao/git/Constitutional_NLP_Summer_2022/venv/senate_1/bverfg.csv'

##### load prepared data
bverfg = pd.read_pickle("bverfg240129.pkl")

##### PREPARE FOR GPT ----
##### token length ----
# Create a new column to store the number of tokens for each observation
bverfg['tokens'] = None

# Loop through each row of the dataset
for i in range(len(bverfg)):
    # Combine the two text parts
    combined_text = f"{bverfg.loc[i, 'short_description']} {bverfg.loc[i, 'full_text']}"
    
    # Tokenize the combined text
    tokens = word_tokenize(combined_text)
    
    # Count the number of tokens and store in the new column
    bverfg.at[i, 'tokens'] = len(tokens)

# Plotting
sns.set_theme(style="whitegrid")
plot = sns.kdeplot(data=bverfg[(bverfg['body'] != "plenary") & (bverfg['body'] != "complaint")], x='tokens', hue='body')
plot.axvline(x=7000, color='r', linestyle='--')
plt.show()

print(bverfg['tokens'].describe())
print(bverfg[bverfg['body'] == "chamber"]['tokens'].describe())
print(len(bverfg[(bverfg['body'] == "chamber") & (bverfg['tokens'] > 4000)]))
print(len(bverfg[(bverfg['body'] == "chamber") & (bverfg['tokens'] > 7000)]))
print(len(bverfg[(bverfg['body'] == "chamber") & (bverfg['sumref'] > 1) & (bverfg['sumdm'] > 1) & (bverfg['tokens'] > 7000)]))

##### senate 1 chamber ----
  #### select relevant cases ----
mult = bverfg[(bverfg['body'] == "senate")].copy()
mult['nrow'] = range(1, len(mult) + 1)

files = sorted(glob.glob(f"{directory}/*.txt"))
num = range(1, len(mult) + 1)
extract = pd.DataFrame({'nrow': num, 'dm': [None] * len(num)})
extract = extract.merge(mult[['id', 'nrow']], on='nrow', how='left')

### loop over all response files
for i, file in enumerate(files):
    with open(file, 'r') as f:
        content = f.readlines()
        hgegenstand_number = re.search(r"Gegenstand\s*(\d+)", content[-1])
        if hgegenstand_number:
            gegenstand_number = re.search(r"\d", hgegenstand_number.group(0)).group(0)
            extract.loc[extract['nrow'] == i + 1, 'dm'] = int(gegenstand_number)

### check for missing values ----
print(extract[extract['dm'].isna()])

### handle these cases manually
manual_corrections = {
    90: 5,
    99: 2,
    186: 1,
    386: 1,
    892: 1,
    1201: 1,
    1280: 1
}

for key, value in manual_corrections.items():
    extract.loc[extract['nrow'] == key, 'dm'] = value

### retrieve name of relevant domain ----
extract['name'] = None

for i in range(len(mult)):
    case_id = extract.loc[i, 'id']
    positive_dm_vars = bverfg[bverfg['id'] == case_id].filter(regex="^dm_").columns[bverfg.loc[bverfg['id'] == case_id, bverfg.filter(regex="^dm_").columns].values.flatten() != 0]
    gegenstand_number = extract.loc[i, 'dm']
    extract.loc[i, 'name'] = positive_dm_vars[int(gegenstand_number) - 1] if gegenstand_number <= len(positive_dm_vars) else None
    print(f"positive_dm_vars = {positive_dm_vars} gegenstand_number = {gegenstand_number}")

### manual corrections ----
extract.loc[extract['nrow'] == 186, 'name'] = "dm_property"
extract.loc[extract['nrow'] == 463, 'name'] = "dm_freedomgeneral"
extract.loc[extract['nrow'] == 1280, 'name'] = "dm_art"

### merge with main dataset ----
bverfg = bverfg.merge(extract[['id', 'dm', 'name']], on='id', how='left')

print(bverfg)

### correct one case where domain cannot be defined ----
bverfg.loc[bverfg['id'] == 7266, 'dm_manifestations'] = 0
bverfg.loc[bverfg['id'] == 7266, 'dm_professions'] = 0

### recalculate number of domains per case ----
bverfg['sumdm'] = bverfg.filter(regex="^dm_").sum(axis=1)

### redefine referee ----
conditions = [
    (bverfg['dm_environmental'] == 1) | (bverfg['dm_property'] == 1) | 
    (bverfg['dm_ip'] == 1) | (bverfg['dm_inheritance'] == 1) | 
    (bverfg['dm_childallowance'] == 1) | (bverfg['dm_developmentcharge'] == 1) | 
    (bverfg['dm_landsale'] == 1) & 
    (bverfg['date'] > "1997-12-31") & (bverfg['date'] < "1998-02-28")
]

bverfg['ref_seidl'] = np.where(conditions[0], 1, 0)

conditions = [
    ((bverfg['date'] > "1998-02-27") & (bverfg['date'] < "1999-12-17") & 
    ((bverfg['dm_farming'] == 1) | (bverfg['dm_childallowance'] == 1) | 
    (bverfg['dm_developmentcharge'] == 1) | (bverfg['dm_landsale'] == 1))) | 
    ((bverfg['date'] > "1998-02-27") & (bverfg['date'] < "2010-03-15") & 
    ((bverfg['dm_environmental'] == 1) | (bverfg['dm_property'] == 1) | 
    (bverfg['dm_ip'] == 1) | (bverfg['dm_inheritance'] == 1)))
]

bverfg['ref_papier'] = np.where(conditions[0], 1, 0)

conditions = [
    ((bverfg['date'] > "1997-12-31") & (bverfg['date'] < "1999-12-17") & 
    (bverfg['dm_postwar'] == 1)) | 
    ((bverfg['date'] > "1997-12-31") & (bverfg['date'] < "2006-10-03") & 
    ((bverfg['dm_taking'] == 1) | (bverfg['dm_tax'] == 1) | 
    (bverfg['dm_levies'] == 1) | (bverfg['dm_construction'] == 1) | 
    (bverfg['dm_planning'] == 1) | (bverfg['dm_landuse'] == 1) | 
    (bverfg['dm_conservation'] == 1) | (bverfg['dm_landconsolidation'] == 1))) | 
    ((bverfg['date'] > "1999-12-16") & (bverfg['date'] < "2006-10-03") & 
    ((bverfg['dm_landsale'] == 1) | (bverfg['dm_developmentcharge'] == 1)))
]

bverfg['ref_haas'] = np.where(conditions[0], 1, 0)

# conditions = [
#     ((bverfg['date'] > "1997-12-31") & (bverfg['date'] < "1999-12-17") & 
#     ((bverfg['dm_association'] == 1) | (bverfg['dm_petitions
