#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 22 15:16:44 2022

@author: tinnguyen
"""


import gdown

url = "https://drive.google.com/file/d/1YVBjmW-7YLtRkAG4dpc0Jd_KqW2fJvS-/view?usp=sharing"
output = "20200929_bverfg_cases.csv"
gdown.download(url=url, output=output, quiet=False, fuzzy=True)


