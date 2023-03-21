import json
import pandas as pd
import datetime
from collections import defaultdict
import numpy as np
import pickle





#df = pd.read_csv('bverfg230107_with_break_noNaN_w_time_aware_features.csv', low_memory=False)
df = pd.read_pickle("bverfg230107_with_break_noNaN_w_time_aware_features.pkl")
#df = df.head(1)

dm_prob_list = ['dm_levies_prob', 'dm2_nationality_prob', 'dm2_parliament_prob', 'dm2_publicservice_prob', 'dm_inheritance_prob', 'dm_tax_prob', 'dm_reunification_prob', 'dm_family_prob', 'dm_property_prob', 'dm_manifestations_prob', 'dm_corporations_prob', 'dm2_parties_prob', 'dm_environmental_prob', 'dm2_crim_prob', 'dm_socialsecurity_prob', 'dm2_victim_prob', 'dm2_prosecution_prob', 'dm2_pretrial_prob', 'dm_professions_prob', 'dm_labour_prob', 'dm_healthinsurance_prob', 'dm2_reinstatement_prob', 'dm_ip_prob', 'dm_competition_prob', 'dm_dataprotection_prob', 'dm_regulation_prob', 'dm2_adminoffence_prob', 'dm_landconsolidation_prob', 'dm_speech_prob', 'dm2_crimenforce_prob', 'dm_freedomgeneral_prob', 'dm2_asylum_prob', 'dm2_foreigner_prob', 'dm2_extradition_prob', 'dm_construction_prob', 'dm2_detention_prob', 'dm2_reopening_prob', 'dm2_church_prob', 'dm2_foreclosure_prob']
print('len(dm_prob_list):', len(dm_prob_list))
judge_prob_list = ['baer_prob', 'britz_prob', 'bross_prob', 'brossss_prob', 'bryde_prob', 'christ_prob', 'difabio_prob', 'eichberger_prob', 'fkirchhof_prob', 'gaier_prob', 'gerhard_prob', 'gerhardt_prob', 'grasshof_prob', 'grimm_prob', 'haas_prob', 'haertel_prob', 'harbarth_prob', 'hassemer_prob', 'hermanns_prob', 'hoemig_prob', 'hoffmannriem_prob', 'hohmanndennhardt_prob', 'huber_prob', 'jaeger_prob', 'jentsch_prob', 'kessalwulf_prob', 'kessalwulff_prob', 'koenig_prob', 'kruis_prob', 'kuehling_prob', 'landau_prob', 'langenfeld_prob', 'limbach_prob', 'luebbewolff_prob', 'maidowski_prob', 'masing_prob', 'mellinghoff_prob', 'osterloh_prob', 'ott_prob', 'papier_prob', 'paulus_prob', 'pkirchhof_prob', 'pmueller_prob', 'radtke_prob', 'schluckebier_prob', 'seibert_prob', 'seidl_prob', 'sommer_prob', 'steiner_prob', 'vosskuhle_prob', 'wallrabenstein_prob', 'winter_prob', 'wolff_prob']
other_main_vars = ['uid', 'date', 'clean_judges', 'domains_of_judges', 'top_author', 'top_author_prob', 'full_text']

relevant_vars_list = dm_prob_list + judge_prob_list + other_main_vars

df = df[relevant_vars_list]

avail_dm_list = [dm_prob[:-5] for dm_prob in dm_prob_list]
#print('avail_dm_list:', avail_dm_list)

avail_judge_list = [judge_prob[:-5] for judge_prob in judge_prob_list]
#print('avail_judge_list:', avail_judge_list)


#Initialize the df with judge-specific, domain-specific features
df_judge_spec_dm_spec = df

#This portion is to get judge-specific (but domains-combined) features
for avail_judge in avail_judge_list:
    df[avail_judge + '_combined_domains_score'] = 0
    df_judge_spec_dm_spec[avail_judge + '_combined_domains_score'] = 0

    for avail_dm in avail_dm_list:
        df_judge_spec_dm_spec[avail_judge + '_' + avail_dm + '_judge_domain_score'] = 0



for row_index, row in df.iterrows():
    domains_of_judges = row['domains_of_judges']
    for judge in domains_of_judges:
        print('judge:', judge)
        domains_of_judge = domains_of_judges[judge]
        #print('domains_of_judge:', domains_of_judge)
        #Check if any time-aware domains of this judge (domains_of_judge) are also in the list of
        #domains with a doc-specific prob returned as and mapped from ATModel's topics (
        domains_of_judge_with_prob = list(set(avail_dm_list) & set(domains_of_judge))
        #print('domains_of_judge_with_prob:', domains_of_judge_with_prob)
        #Look up the ATModel returned prob of each domain (if available) of the judge, then sum those probs up for every judge on the case
        judge_combined_domains_score = 0
        for domain_of_judge_with_prob in domains_of_judge_with_prob:
            domain_of_judge_with_prob_str = domain_of_judge_with_prob + '_prob'
            domain_prob = row[domain_of_judge_with_prob_str]
            print('domain_of_judge_with_prob_str:', domain_of_judge_with_prob_str)
            print('domain_prob:', domain_prob)
            judge_combined_domains_score += domain_prob

            #This portion updates the judge-specific, domain-specific score features
            judge_spec_dm_spec_var = judge + '_' + domain_of_judge_with_prob + '_judge_domain_score'
            print('judge_spec_dm_spec_var:', judge_spec_dm_spec_var)
            df_judge_spec_dm_spec.at[row_index, judge_spec_dm_spec_var] = domain_prob


        print('judge_combined_domains_score:', judge_combined_domains_score)

        df.at[row_index, judge + '_combined_domains_score'] = judge_combined_domains_score
        df_judge_spec_dm_spec.at[row_index, judge + '_combined_domains_score'] = judge_combined_domains_score

#Save data
df.to_csv('bverfg230107_with_break_noNaN_w_time_aware_judge_specific_features.csv')
df.to_pickle("bverfg230107_with_break_noNaN_w_time_aware_judge_specific_features.pkl")

df_judge_spec_dm_spec.to_csv('bverfg230107_with_break_noNaN_w_time_aware_judge_spec_dm_spec_features.csv')
df_judge_spec_dm_spec.to_pickle("bverfg230107_with_break_noNaN_w_time_aware_judge_spec_dm_spec_features.pkl")