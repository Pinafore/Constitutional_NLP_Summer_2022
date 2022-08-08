20200929_bverfg_cases.csv:
	python3 Download_Raw_Data.py

case_scraping_Aug_01_2022.csv:
	python3 Download_Updated_Data.py

author2doc_Aug_01_2022.json: Generate_author2doc.py
	python3 Generate_author2doc.py

stop_words_Aug_01_2022: Construct_stop_words_Aug_01_2022.py
	python3 Construct_stop_words_Aug_01_2022.py

at_model_author_vecs.txt: Author_Topic_Model_Aug_01_2022.py
	python3 -m spacy download de_core_news_md
	python3 Author_Topic_Model_Aug_01_2022.py

at_model_topics.txt: Author_Topic_Model_Aug_01_2022.py
	python3 -m spacy download de_core_news_md
	python3 Author_Topic_Model_Aug_01_2022.py

lda_model_topics.txt: LDA_Model_Aug_01_2022.py
	python3 LDA_Model_Aug_01_2022.py

lda_model_most_likely_topic_per_doc.txt: LDA_Model_Aug_01_2022.py
	python3 LDA_Model_Aug_01_2022.py