import json
from collections import defaultdict
with open('clean_author2doc_01_1998_to_07_2022_noNaN.json', 'r') as f:
    author2doc = json.load(f)
print('author2doc:', author2doc)

def invert(my_map):
    inv_map = defaultdict(list)
    for node, neighbours in my_map.items():
        for neighbour in neighbours:
            inv_map[neighbour].append(node)
    return inv_map

doc2author = invert(author2doc)
print('doc2author:', doc2author)
print('len(doc2author):', len(doc2author))
key_list = sorted(doc2author.keys(), reverse=True)
print('doc2author.keys():', sorted(doc2author.keys(), reverse=True))
for i in range(8112):
    if i not in key_list:
        print('missing:', i)
        doc2author[i] = ["UNK"]
print('doc2author:', doc2author)
print('len(doc2author):', len(doc2author))

authors_per_doc_lol = []
for key in sorted(doc2author.keys()):
    print('key:', key)
    authors_per_doc_lol.append(doc2author[key])
print('authors_per_doc_lol:', authors_per_doc_lol)
print('len(authors_per_doc_lol):', len(authors_per_doc_lol))

with open('authors_per_doc_lol.json', 'w') as f:
    json.dump(authors_per_doc_lol, f)
with open('authors_per_doc_lol.json', 'r') as f:
    authors_per_doc_lol = json.load(f)

print('len(authors_per_doc_lol):', len(authors_per_doc_lol))