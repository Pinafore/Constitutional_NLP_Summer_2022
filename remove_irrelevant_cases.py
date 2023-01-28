import pandas as pd
import re
import numpy as np
#df = pd.read_csv('case_scraping_Dec_04_2022.csv')
df = pd.read_csv('bverfg230107_with_break.csv')

#updated_df = df.drop([df.index[i] for i in range(0,233)])
updated_df = df.drop([df.index[i] for i in range(0,3)])
drop_indices = []
for idx, row in updated_df.iterrows():
    row['full_text'] = row['full_text'].replace('\n', '')
    row['full_text'] = re.sub(' +', ' ', row['full_text'])
    #if len(row['judges']) < 3 or len(row['full_text']) < 3:
    #Remove cases with emty authors or too short full_text
    if len(row['full_text'].split(' ')) < 100:
        print("row['full_text']: ", row['full_text'])
        print("len of full_text:", len(row['full_text'].split(' ')))
        print("row['full_text'].split(" "):", row['full_text'].split(' '))
        drop_indices += [idx]
        #updated_df = updated_df.drop(idx)

for idx, row in updated_df.iterrows():
    if len(row['judges']) < 3:
        print("row['judges']:", row['judges'])
        drop_indices += [idx]

updated_df = updated_df.drop(drop_indices)
#Remove less important columns to mitigate the effect of dropping rows with any empty entries
#updated_df.drop(columns=['senate_and_chamber', 'decision'], axis=1, inplace=True)

#updated_df.dropna(axis=0, how='any', inplace=True)
#Create an additional uid column (updated id) with index ranging from 0 to 1
idx = 0
updated_df.insert(idx, 'uid', value=np.arange(len(updated_df)))

#updated_df.to_csv('case_scraping_01_1998_to_07_2022.csv', index=False)
updated_df.to_csv('bverfg230107_with_break_noNaN.csv', index=False)

print('before:', len(df.index))
print('after:', len(updated_df.index))
#print('updated_df[0:2]:', updated_df[0:2])
#print('updated_df[8185:8187]:', updated_df[8185:8187])
#print('updated_df.shape[0]: ', updated_df.shape[0])