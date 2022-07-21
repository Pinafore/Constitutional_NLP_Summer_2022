# -*- coding: utf-8 -*-
"""
Created on Thu Jul 21 01:30:59 2022

@author: Acer
"""

import gdown

url = "https://drive.google.com/drive/folders/10Gsuxs5T38uFnMOzHbL5d7LJOkMVxFKF?usp=sharing"
output = "Case_Scraping_with_BeautifulSoup_July_18_2022.py.csv"
gdown.download(url=url, output=output, quiet=False, fuzzy=True)
