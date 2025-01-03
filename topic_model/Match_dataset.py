"""
Time: Thu Dec 8

@author: Jiannan, Tin
"""

import pandas as pd
import dateparser


# match the latest data set with the old one
def match_df(df_old,df_latest):
    # change double quatation to single quatation
    df_old['docket_numbers_modified'] = df_old['az'].apply(lambda x: x.replace('"',"'"))

    # change the date strings into datetime64[ns] 
    df_old['beschluss_date_string_modified'] = df_old['beschluss_date_string'].apply(lambda x: x if isinstance(x, float) else dateparser.parse(x))
    df_latest['decision_date_modified'] = df_latest['decision_date'].apply(lambda x: x if isinstance(x, float) else dateparser.parse(x))
    df_latest['uid'] = range(0,df_latest.shape[0])
    df_latest_updated = pd.merge(df_latest,df_old,how='left',
                                left_on=['docket_numbers','decision_date_modified'], \
                                right_on=['docket_numbers_modified','beschluss_date_string_modified'])
                
    return df_latest_updated
    
if __name__ == "__main__":
    df_old = pd.read_csv('Data/BVerfG220605.csv')
    df_latest = pd.read_csv('Data/case_scraping_01_1998_to_07_2022_noNaN.csv')
    df_latest_updated = match_df(df_old, df_latest)
    print(df_latest_updated)
    df_latest_updated.to_csv('Data/case_scraping_01_1998_to_07_2022_noNaN_all.csv')
    