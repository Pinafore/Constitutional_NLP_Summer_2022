# -*- coding: utf-8 -*-
"""
Created on Sat Jul  9 17:26:36 2022

@author: Acer
"""
import urllib.request, urllib.parse, urllib.error
from bs4 import BeautifulSoup as bs
import ssl

# --- ignore ssl certificate ---
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE


url = 'https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gtp=5403124_list%253D592&language_=de'

html = urllib.request.urlopen(url, context=ctx).read() 

soup = bs(html, 'html.parser') 
#print(soup.prettify())
#case_file = open("one_case_28_07_2015.txt", "w")
case_file = open("big_url_592.txt", "w")
n = case_file.write(str(soup.prettify()))
case_file.close()