20200929_bverfg_cases.csv:
	python3 Download_Raw_Data.py

case_scraping_Aug_01_2022.csv:
	python3 Download_Updated_Data.py

author2doc.json: Generate_author2doc.py
	python3 Generate_author2doc.py

Author_Topic_Model_author_vecs.txt: Author_Topic_Model_Raw_Data.py
	python3 -m spacy download de_core_news_md
	python3 Author_Topic_Model_Raw_Data.py