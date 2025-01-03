import pandas as pd

df = pd.read_csv('case_scraping_Aug_01_2022.csv')
updated_df = df.drop([df.index[i] for i in range(0,233)])
for idx, row in updated_df.iterrows():
    if len(row['participating_judges']) < 3 or len(row['full_text']) < 3:
        updated_df = updated_df.drop(idx)
#Remove less important columns to mitigate the effect of dropping rows with any empty entries
#updated_df.drop(columns=['senate_and_chamber', 'short_description', 'decision'], axis=1, inplace=True)
updated_df.drop(columns=['senate_and_chamber', 'decision'], axis=1, inplace=True)
#Remove any row that contains an empty entry, e.g. authors, full_text
updated_df.dropna(axis=0, how='any', inplace=True)
#updated_df.to_csv('case_scraping_01_1998_to_07_2022.csv', index=False)
updated_df.to_csv('case_scraping_01_1998_to_07_2022_noNaN.csv', index=False)
print('updated_df[0:2]:', updated_df[0:2])
print('updated_df.shape[0]: ', updated_df.shape[0])