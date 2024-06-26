# Legal NLP with Topic Models


1. How to download the two relevant csv files locally?

1.a. Court decision data:
Get case_scraping_Aug_01_2022.csv from the Makefile on Github, or go to the Google Drive folder: 

Legal NLP Project (with MPI Coll) -> Updated Data -> case_scraping_Aug_01_2022.csv .

Some variables (columns) of current interest are 'participating_judges' and 'full_text'.

1.b. Ground-truth domains of each author (1998-2022): https://docs.google.com/spreadsheets/d/1xf3cCwArTWHxHNR_7T9D5vjafiw3P18L/edit#gid=1305781617

2.1. How to run LDA?

Make sure you have downloaded both Data_Preprocessing_for_Topic_Models.py and LDA_Model.py , then run LDA_Model.py . You can change the number of topics (default = 37) by call the flag --num_topics . For example, run this command to get results with 10 topics: python3 LDA_Model.py --num_topics 10

-> Which section to comment out to avoid training the model again, but use a trained and saved model (instructions in .py file; Don't forget to download the model file too):
  
  model = fit_model(dictionary, cases, flags.model_save, num_topics=flags.num_topics)


2.2. Relevant distributions returned by running LDA?

Words (i.e. tokens) per topic: Legal NLP Project (with MPI Coll) -> Results -> LDA Model -> lda_model_topics.txt

(Most likely) Topic(s) per document: Legal NLP Project (with MPI Coll) -> Results -> LDA Model -> lda_model_most_likely_topic_per_doc.txt


3.1. How to run Author-Topic (AT) model (any dependency)?

Make sure you have downloaded both Data_Preprocessing_for_Topic_Models.py , Author_Topic_Model.py , and the dependency author2doc.json, then run Author_Topic_Model.py . You can change the number of topics (default = 37) by call the flag --num_topics . For example, run this command to get results with 10 topics: python3 Author_Topic_Model.py --num_topics 10

-> Which section to comment out to avoid training the model again, but use a trained and saved model: instructions in .py file; Don't forget to download the model file too!


3.2. Relevant distributions returned by running AT model?

Words (i.e. tokens) per topic: Legal NLP Project (with MPI Coll) -> Results -> AT model with varying number of topics -> at_model_topics_num_topics=[a number].txt

Topics per author: Legal NLP Project (with MPI Coll) -> Results -> AT model with varying number of topics -> at_model_author_vecs_num_topics=[a number].txt


4. Resources to double check the authors (judges)?

Wiki page of all judges in the court (the participating_judges variable in csv file only shows their last name): https://de.wikipedia.org/wiki/Liste_der_Richter_des_Bundesverfassungsgerichts

Link of raw data (before scraping) to compare approx case id with year (note: smaller id means older cases; cases with id 10 or above probably decided after 1990s): https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gts=5403124_list%253Ddate_dt%252Basc&language_=de


AT Model Code Pipeline:
-> remove_irrelevant_cases.py
-> Data_Preprocessing_for_Topic_Models.py
-> Generate_author2doc.py
-> Clean_author2doc.py
-> Convert_author2doc_to_lol.py
-> AT_Model_Gibbs_WardNJU.py

Evaluation Pipeline:
-> calculate_coherence.py
-> automatic_topic_to_domain_map.py
-> save_full_topics_per_doc_dist.py
-> get_features_domain_and_author_probs_per_doc.py
-> augment_clean_judges_to_csv.py
-> get_time_aware_features.py
-> get_time_aware_judge_specific_features.py
