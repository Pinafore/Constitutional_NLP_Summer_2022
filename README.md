# Legal NLP with Topic Models
1. How to download the scraped dataset locally?
Get case_scraping_Aug_01_2022.csv from the Makefile on Github, or go to the Google Drive folder: 
Legal NLP Project (with MPI Coll) -> Updated Data -> case_scraping_Aug_01_2022.csv
Some variables (columns) of current interest are 'participating_judges' and 'full_text'.

2.1. How to run LDA?
Run the

-> Which section to comment out to avoid training the model again, but use a trained and saved model:

2.2. Relevant distributions returned by running LDA?


3.1. How to run Author-Topic (AT) model (any dependency)?

-> Which section to comment out to avoid training the model again, but use a trained and saved model:

3.2. Relevant distributions returned by running AT model?

4. Resources to double check the authors (judges)?
Wiki page of all judges in the court (the participating_judges variable in csv file only shows their last name): https://de.wikipedia.org/wiki/Liste_der_Richter_des_Bundesverfassungsgerichts

Link of raw data (before scraping) to compare approx case id with year (note: cases with id 10 or above probably decided after 1990s): https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gts=5403124_list%253Ddate_dt%252Basc&language_=de



