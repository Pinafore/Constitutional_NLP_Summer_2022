# -*- coding: utf-8 -*-
"""
Created on Thu Jul 21 01:30:59 2022

@author: Acer
"""

import gdown

url = "https://drive.google.com/file/d/1VBV57lpj0xMotY2a_8Io_fdvDLKdP6y8/view?usp=sharing"
output = "case_scraping_Aug_01_2022.csv"
gdown.download(url=url, output=output, quiet=False, fuzzy=True)
