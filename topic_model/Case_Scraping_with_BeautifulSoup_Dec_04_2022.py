import urllib.request, urllib.parse, urllib.error
from bs4 import BeautifulSoup as bs
import ssl
import numpy as np
import re
import csv


# ignore ssl certificate 
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
'''
label_row = ['bverfg_id_forward', 'date_and_first_docket', 'docket_numbers', 'senate_and_chamber', 'participating_judges', 'decision_date', 'short_description' , 'decision', 'full_text', 'url']
with open('case_scraping_Dec_04_2022.csv', mode='w') as case_file:
    case_writer = csv.writer(case_file, delimiter=',',  quotechar='"', quoting=csv.QUOTE_MINIMAL)
    case_writer.writerow(label_row)
    case_file.close()
'''


def parse_case(url):
    # def parse_case(url, bverfg_id_forward):
    # global bverfg_id_forward #access a global variable inside a function
    global bverfg_id_forward
    bverfg_id_forward = bverfg_id_forward + 1
    print('bverfg_id_forward =', bverfg_id_forward)
    print('url =', url)
    case_row = []
    html = urllib.request.urlopen(url, context=ctx).read()

    soup = bs(html, 'html.parser')
    # print(soup.prettify())

    # Use find_all because a case may belong to more than 1 docket
    date_docket = soup.find('strong', string=re.compile('Beschluss vom|Urteil vom'))
    date_docket = date_docket.text.strip()
    if date_docket[:14] == 'Beschluss vom ':
        date_docket = date_docket[14:]  # take out the 'Beschluss vom ' portion
    else:
        date_docket = date_docket[11:]  # alternatively, take out the 'Urteil vom ' portion

    try:
        date, docket = date_docket.split(' - ')
    except:  # in case the docket number is N/A
        date = date_docket
        docket = ''

    print('date_docket =', date_docket)
    # print('date =' + date)
    # print('docket =' + docket)

    dockets = soup.find_all('p', class_='az2')  # , string=' - 2 BvR 2558/14 - ')#, string=re.compile('^ -.*- $'))
    docket_list = []
    try:
        disallowed_chars = ['- ', ' -', '-', ',', '\n']
        for docket in dockets:
            docket = docket.get_text().strip()
            for disallowed_char in disallowed_chars:
                docket = docket.replace(disallowed_char, '')
            # if docket[-1] == ',':
            #    docket = docket[:-1]
            docket_list.append(docket)
        docket_list = set(docket_list)  # avoid repeating elements
    except:
        docket_list = ''

    print('docket_list = ', docket_list)

    try:
        short_des = soup.find('title')
        short_des = short_des.get_text().strip()
        print('short_des =', short_des)
    except:
        short_des = ''

    try:
        decision = soup.find('li', class_="bs")
        decision = decision.get_text().strip()
        print('decision =', decision)
    except:
        decision = ''

    senate_chamber = soup.find('meta', attrs={'name': 'DC.creator'})
    senate_chamber = senate_chamber.get('content')
    senate_chamber = senate_chamber.split(',')[1]
    print('senate_chamber =', senate_chamber)

    authors = soup.find_all('td', class_='st')
    disallowed_chars = ['Dr.', 'h.', 'c.', 'Richterinnen', 'Richterin', 'Richter', ' ']
    author_list = []
    for author in authors:
        author = author.text.strip()
        for disallowed_char in disallowed_chars:
            author = author.replace(disallowed_char, '')
        author_list.append(author)
    print('author_list =', author_list)

    #full_texts = soup.find_all('div', class_='entscheidung')
    #Use find instead of find_all to avoid the second ('div', class_='entscheidung') tag which gives useless info ECLI:
    #e.g. ECLI:DE:BVerfG:1997:rk19971230.1bvr226497Zitiervorschlag:BVerfG, Beschluss der 1. Kammer des Ersten Senats vom 30. Dezember 1997 - 1 BvR 2264/97 -, Rn. 1-20,http://www.bverfg.de/e/rk19971230_1bvr226497.htmlSiehe auch PressemitteilungNr. 1/1998 vom 13. Januar 1998PDF-Download
    full_texts = soup.find('div', class_='entscheidung')
    full_text_str = ''
    for full_text in full_texts:
        full_text = full_text.text.strip()
        full_text_str = full_text_str + full_text
    # print('full_text_str =', full_text_str)

    case_row.append(bverfg_id_forward)
    case_row.append(date_docket)
    case_row.append(docket_list)
    case_row.append(senate_chamber)
    case_row.append(author_list)
    case_row.append(date)
    case_row.append(short_des)
    case_row.append(decision)
    case_row.append(full_text_str)
    case_row.append(url)
    # print('case_row =', case_row)
    # return case_row, bverfg_id_forward
    return case_row


def process_ten_cases(main_url, idx):
    bverfg_id_forward = (idx - 1) * 10
    main_html = urllib.request.urlopen(main_url, context=ctx).read()
    main_soup = bs(main_html, 'html.parser')
    case_links = main_soup.find_all('a', href=re.compile('^SharedDocs/Entscheidungen/DE'))
    case_link_list = []
    for case_link in case_links:
        case_link = case_link.get('href')
        case_link = 'https://www.bundesverfassungsgericht.de/' + case_link
        case_link_list.append(case_link)
    # print('case_link_list =', case_link_list)

    case_mtrx = []

    for case_link in case_link_list:
        # case_row, bverfg_id_forward = parse_case(url=case_link, bverfg_id_forward=bverfg_id_forward)
        case_row = parse_case(url=case_link)
        case_mtrx.append(case_row)

    with open('case_scraping_Dec_04_2022.csv', mode='a') as case_file:  # append mode
        case_writer = csv.writer(case_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        case_writer.writerows(case_mtrx)
        case_file.close()


if __name__ == "__main__":
    bverfg_id_forward = 0
    # ignore ssl certificate
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    label_row = ['bverfg_id_forward', 'date_and_first_docket', 'docket_numbers', 'senate_and_chamber',
                 'participating_judges', 'decision_date', 'short_description', 'decision', 'full_text', 'url']

    with open('case_scraping_Dec_04_2022.csv', mode='w') as case_file:
        case_writer = csv.writer(case_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        case_writer.writerow(label_row)
        case_file.close()

    for idx in np.arange(24, 849):
        main_url = 'https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gts=5403124_list%253Ddate_dt%252Basc&gtp=5403124_list%253D' + str(
            idx) + '&language_=de'
        process_ten_cases(main_url, idx)