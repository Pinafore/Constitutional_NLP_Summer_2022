#Source code: https://github.com/Ward-nju/Topic-Model/blob/master/ATMGibbs.py

import numpy as np
from scipy.special import gamma
from collections import OrderedDict
import pandas as pd
from numba import jit
from datetime import datetime

from collections import Counter, defaultdict

import json
import pickle
import argparse


class DataPreProcessing(object):
    def __init__(self):
        self.docs_count = 0
        self.words_count = 0
        self.authors_count = 0
        self.docs = []
        self.authors = []
        self.word2id = OrderedDict()
        self.id2word = OrderedDict()
        self.author2id = OrderedDict()
        self.id2author = OrderedDict()


def preprocessing(corpus, authors):
    if len(corpus) != len(authors):
        print('errors occur:corpus and authors have different length!')
    else:
        word_index = 0
        dpre = DataPreProcessing()
        for sentence in corpus:
            s = []
            for word in sentence:
                if word in dpre.word2id.keys():
                    s.append(dpre.word2id[word])
                else:
                    dpre.word2id[word] = word_index
                    s.append(word_index)
                    word_index += 1
            print('s:', s)
            dpre.docs.append(s)
        author_index = 0
        for author in authors:
            alist = []
            for a in author:
                if a in dpre.author2id.keys():
                    alist.append(dpre.author2id[a])
                else:
                    dpre.author2id[a] = author_index
                    alist.append(author_index)
                    author_index += 1
            dpre.authors.append(alist)

        dpre.docs_count = len(dpre.docs)
        dpre.words_count = len(dpre.word2id)
        dpre.authors_count = author_index
        dpre.id2word = {v: k for k, v in dpre.word2id.items()}
        dpre.id2author = {v: k for k, v in dpre.author2id.items()}
        print('dpre.docs_count:', dpre.docs_count)
        print('dpre.words_count:', dpre.words_count)
        print('dpre.authors_count:', dpre.authors_count)
        print('dpre.id2word:', dpre.id2word)
        print('dpre.id2author:', dpre.id2author)
        print('dpre.docs:', dpre.docs)
        print('dpre.authors:', dpre.authors)
        return dpre


class ATM(object):
    """
    Author Topic Model
    implementation of `The Author-Topic Model for Authors and Documents` by Rosen-Zvi, et al. (2004)
    """

    def __init__(self, dpre, K, beta=0.01, max_iter=100, seed=1):
        # initial var
        self.dpre = dpre
        self.A = dpre.authors_count
        self.K = K #number of topics
        self.V = dpre.words_count
        self.alpha = 50/K
        self.beta = beta
        self.max_iter = max_iter
        self.seed = seed

        self.at = np.zeros([self.A, self.K], dtype=int)  # authors*topics
        self.tw = np.zeros([self.K, self.V], dtype=int)  # topics*words
        self.atsum = self.at.sum(axis=1)
        self.twsum = self.tw.sum(axis=1)

        self.Z_assignment = np.array([[0 for y in range(len(self.dpre.docs[x]))] for x in
                                     range(self.dpre.docs_count)])  # topic assignment for each word for each doc
        self.A_assignment = np.array([[0 for y in range(len(self.dpre.docs[x]))] for x in
                                     range(self.dpre.docs_count)])  # author assignment for each word for each doc

        # output var:
        self.theta = np.array([[0.0 for y in range(self.K)] for x in range(self.A)])
        self.phi = np.array([[0.0 for y in range(self.V)] for x in range(self.K)])

    @jit
    def initializeModel(self):
        # initialization
        print('init start:', datetime.now())
        np.random.seed(self.seed)

        for m in range(self.dpre.docs_count):
            #print('m:', m)
            for n in range(len(self.dpre.docs[m])):  # n is word's index
                #print('n:', n)
                # 选主题
                # k=np.random.multinomial(1,[1/self.K]*self.K).argmax()
                k = np.random.randint(low=0, high=self.K)

                # 选作者
                if len(self.dpre.authors[m]) == 1:  # 这篇文章只有一个作者，那就是TA
                    a = self.dpre.authors[m][0]
                else:  # 若有多个作者，随机选择一个
                    idx = np.random.randint(low=0, high=len(self.dpre.authors[m]))
                    a = self.dpre.authors[m][idx]

                self.at[a, k] += 1
                self.atsum[a] += 1
                self.tw[k, self.dpre.docs[m][n]] += 1
                self.twsum[k] += 1
                self.Z_assignment[m][n] = k
                self.A_assignment[m][n] = a

        print('init finish:', datetime.now())

    @jit
    def inferenceModel(self):
        self.initializeModel()

        print('inference start:', datetime.now())

        cur_iter = 0
        while cur_iter <= self.max_iter:
            for m in range(self.dpre.docs_count):
                for n in range(len(self.dpre.docs[m])):  # n is word's index
                    self.sample(m, n)
            print(cur_iter, datetime.now())
            cur_iter += 1

        print('inference finish:', datetime.now())

        self.updateEstimatedParameters()

    @jit
    def sample(self, m, n):
        old_topic = self.Z_assignment[m][n]
        old_author = self.A_assignment[m][n]
        word = self.dpre.docs[m][n]
        authors_set = self.dpre.authors[m]

        self.at[old_author, old_topic] -= 1
        self.atsum[old_author] -= 1
        self.tw[old_topic, word] -= 1
        self.twsum[old_topic] -= 1

        section1 = (self.tw[:, word] + self.beta) / (self.twsum + self.V * self.beta)
        section2 = (self.at[authors_set, :] + self.alpha) / (
                    self.atsum[authors_set].repeat(self.K).reshape(len(authors_set), self.K) + self.K * self.alpha)
        p = section1 * section2
        #print('p before:', p)

        p = p.reshape(len(authors_set) * self.K)
        #print('p after:', p)
        #print('np.random.multinomial(1, p / p.sum()):', np.random.multinomial(1, p / p.sum()))
        index = np.random.multinomial(1, p / p.sum()).argmax()
        #print('index:', index)

        #print('self.K:', self.K)
        #print('authors_set:', authors_set)

        new_author = authors_set[int(index / self.K)]
        new_topic = index % self.K
        """
        p=np.array([[0.0 for y in range(self.K)] for x in range(self.dpre.authors_count)])
        for a in self.dpre.authors[m]:   #!
            for k in range(self.K):
                p[a,k]=(tw[k,word]+self.beta)/(twsum[k]+self.dpre.words_count*self.beta) \
                        *(at[a,k]+self.alpha)/(atsum[a]+self.K*self.alpha)
                    #print(p)
        p=p.reshape(self.dpre.authors_count*self.K)
        index=np.random.multinomial(1,p/p.sum()).argmax()
        author=int(index/self.K)
        topic=index%self.K
        """
        self.at[new_author, new_topic] += 1
        self.atsum[new_author] += 1
        self.tw[new_topic, word] += 1
        self.twsum[new_topic] += 1
        self.Z_assignment[m][n] = new_topic
        self.A_assignment[m][n] = new_author
        #print('self.Z_assignment:', self.Z_assignment)
        #print('self.A_assignment:', self.A_assignment)

    @jit
    def updateEstimatedParameters(self):
        for a in range(self.A):
            self.theta[a] = (self.at[a] + self.alpha) / (self.atsum[a] + self.alpha * self.K)
        for k in range(self.K):
            self.phi[k] = (self.tw[k] + self.beta) / (self.twsum[k] + self.beta * self.V)

    def print_tw(self, topN=1000):
        topics = {}
        for k in range(self.K):
            topic = []
            index = self.phi[k].argsort()[::-1][:topN]
            for ix in index:
                prob = ("%.3f" % self.phi[k, ix])
                word = self.dpre.id2word[ix]
                #topic.append((prob, word))
                topic.append(word)
            #topics.append(topic)
            topics[k] = topic
        '''
        with open('WardNJU_words_per_topic_num_topics=' + str(self.K) + '.json', 'w') as f:
            json.dump(topics, f)

        with open('WardNJU_words_per_topic_num_topics=' + str(self.K) + '.json', 'r') as f:
            topics = json.load(f)
        '''

        with open('WardNJU_words_per_topic_num_topics=' + str(self.K) + '.json', 'wb') as f:
            pickle.dump(topics, f)

        with open('WardNJU_words_per_topic_num_topics=' + str(self.K) + '.json', 'rb') as f:
            topics = pickle.load(f)

        with open('WardNJU_words_per_topic_num_topics=' + str(self.K) + '.txt', "w") as f:
            n = f.write(str(topics))

        return topics


    def symmetric_KL_divergence(self, i, j):
        # caculate symmetric KL divergence between author i and j
        # i,j: author name or author id
        if type(i) != int or type(j) != int:
            i = self.dpre.author2id[i]
            j = self.dpre.author2id[j]
        sKL = 0
        for k in range(self.K):
            sKL += self.theta[i, k] * np.log(self.theta[i, k] / self.theta[j, k]) \
                   + self.theta[j, k] * np.log(self.theta[j, k] / self.theta[i, k])
        return sKL



    def print_at(self, topN=7):
        authors = {}
        for a in range(self.A):
            author = []
            index = self.theta[a].argsort()[::-1][:topN]
            for ix in index:
                prob = ("%.3f" % self.theta[a, ix])
                topic = ix
                author.append((prob, topic))
            author_name = self.dpre.id2author[a]
            authors[author_name] = author
        '''
        with open('WardNJU_topics_per_author_num_topics=' + str(self.K) + '.json', 'w') as f:
            json.dump(authors, f)

        with open('WardNJU_topics_per_author_num_topics=' + str(self.K) + '.json', 'r') as f:
            authors = json.load(f)
        '''
        with open('WardNJU_topics_per_author_num_topics=' + str(self.K) + '.json', 'wb') as f:
            pickle.dump(authors, f)

        with open('WardNJU_topics_per_author_num_topics=' + str(self.K) + '.json', 'rb') as f:
            authors = pickle.load(f)

        with open('WardNJU_topics_per_author_num_topics=' + str(self.K) + '.txt', "w") as f:
            n = f.write(str(authors))

        return authors


    def print_topics_per_doc(self, topN=3):
        topics_prob_per_doc_all = {} #dict of dict
        for m in range(self.dpre.docs_count):
            z_doc = self.Z_assignment[m]
            #print('z_doc:', z_doc)
            z_keys, z_counts = np.array(list(Counter(z_doc).keys())), np.array(list(Counter(z_doc).values()))
            z_probs = np.array([round(z_count/sum(z_counts),2) for z_count in z_counts])
            #print('z_keys:', z_keys)
            #print('z_counts:', z_counts)
            #print('z_probs:', z_probs)
            if len(z_counts) > topN:
                top_indices = z_counts.argsort()[::-1][:topN]
                z_keys = z_keys[top_indices]
                z_probs = z_probs[top_indices]
                #print('top z_keys:', z_keys)
                #print('top z_probs:', z_probs)
            topic_prob_per_doc_dict = {}
            for idx in range(len(z_keys)):
                topic_prob_per_doc_dict[str(z_keys[idx])] = z_probs[idx]
            #print('topic_prob_per_doc_dict:', topic_prob_per_doc_dict)
            #print('Document {} has most likely topics:{}'.format(m, topic_prob_per_doc_dict))
            topics_prob_per_doc_all[m] = topic_prob_per_doc_dict

        '''
        with open('WardNJU_topics_per_doc_num_topics=' + str(self.K) + '.json', 'w') as f:
            json.dump(topics_prob_per_doc_all, f)

        with open('WardNJU_topics_per_doc_num_topics=' + str(self.K) + '.json', 'r') as f:
            topics_prob_per_doc_all = json.load(f)
        '''

        with open('WardNJU_topics_per_doc_num_topics=' + str(self.K) + '.json', 'wb') as f:
            pickle.dump(topics_prob_per_doc_all, f)

        with open('WardNJU_topics_per_doc_num_topics=' + str(self.K) + '.json', 'rb') as f:
            topics_prob_per_doc_all = pickle.load(f)

        with open('WardNJU_topics_per_doc_num_topics=' + str(self.K) + '.txt', "w") as f:
            n = f.write(str(topics_prob_per_doc_all))

        print('topics_prob_per_doc_all:', topics_prob_per_doc_all)



    def print_authors_per_doc(self, topN=8):
    #def print_authors_per_doc(self, topN=3):
        authors_prob_per_doc_all = {} #dict of dict
        for m in range(self.dpre.docs_count):
            a_doc = self.A_assignment[m]
            print('a_doc:', a_doc)
            a_keys, a_counts = np.array(list(Counter(a_doc).keys())), np.array(list(Counter(a_doc).values()))
            a_keys = np.array([self.dpre.id2author[a] for a in a_keys])
            a_probs = np.array([round(a_count/sum(a_counts),2) for a_count in a_counts])
            print('a_keys:', a_keys)
            print('a_counts:', a_counts)
            print('a_probs:', a_probs)
            if len(a_counts) > topN:
                top_indices = a_counts.argsort()[::-1][:topN]
            else:
                top_indices = a_counts.argsort()[::-1]
            print('top_indices:', top_indices)
            a_keys = a_keys[top_indices]
            a_probs = a_probs[top_indices]
            print('top a_keys:', a_keys)
            print('top a_probs:', a_probs)
            author_prob_per_doc_dict = {}
            for idx in range(len(a_keys)):
                author_prob_per_doc_dict[str(a_keys[idx])] = a_probs[idx]
            print('author_prob_per_doc_dict:', author_prob_per_doc_dict)
            print('Document {} has most likely authors:{}'.format(m, author_prob_per_doc_dict))
            authors_prob_per_doc_all[m] = author_prob_per_doc_dict
            '''
            with open('WardNJU_authors_per_doc_num_topics=' + str(self.K) + '.json', 'w') as f:
                json.dump(authors_prob_per_doc_all, f)

            with open('WardNJU_authors_per_doc_num_topics=' + str(self.K) + '.json', 'r') as f:
                authors_prob_per_doc_all = json.load(f)
            '''

            with open('WardNJU_authors_per_doc' + '_topN=' + str(topN) + '_num_topics=' + str(self.K) + '.json', 'wb') as f:
                pickle.dump(authors_prob_per_doc_all, f)

            with open('WardNJU_authors_per_doc' + '_topN=' + str(topN) + '_num_topics=' + str(self.K) + '.json', 'rb') as f:
                authors_prob_per_doc_all = pickle.load(f)

            with open('WardNJU_authors_per_doc' + '_topN=' + str(topN) + '_num_topics=' + str(self.K) + '.txt', "w") as f:
                n = f.write(str(authors_prob_per_doc_all))

            print('authors_prob_per_doc_all:', authors_prob_per_doc_all)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Implement AT Model with Gibbs")
    parser.add_argument('--num_topics', type=int, default=100)

    flags = parser.parse_args()

    with open('authors_per_doc_lol_bverfg230107.json', 'r') as f:
        authors_per_doc_lol = json.load(f)

    #with open('read_cases_manualATM_text_list.json', 'r') as f:
    with open('read_cases_manualATM_text_list_bverfg230107.json', 'r') as f:
        read_cases_manualATM_text_list = json.load(f)

    #corpus = [['computer', 'medical', 'DM', 'algorithm', 'drug', 'computer'],
    #          ['computer', 'AI', 'DM', 'algorithm'],
    #          ['art', 'beauty', 'architectural'],
    #          ['drug', 'medical', 'hospital']]
    #authors = [['Tom', 'Amy'], ['Tom'], ['Ward'], ['Amy']]
    dpre = preprocessing(corpus=read_cases_manualATM_text_list, authors=authors_per_doc_lol)
    print('done with preprocessing')

    model = ATM(dpre, K=flags.num_topics, max_iter=100)
    #print('initial model.theta:', model.theta)
    #print('initial model.phi:', model.phi)
    #print('initial model.Z_assignment:', model.Z_assignment)
    #print('initial model.A_assignment:', model.A_assignment)
    model.inferenceModel()
    #print('model.theta:', model.theta)
    #print('model.phi:', model.phi)
    #print('final model.Z_assignment:', model.Z_assignment)
    #print('final model.A_assignment:', model.A_assignment)
    topics = model.print_tw()
    #print('topics:', topics)
    authors = model.print_at()
    #print('authors:', authors)
    model.print_topics_per_doc()
    model.print_authors_per_doc()
    #Save the highest-probability judge per doc
    model.print_authors_per_doc(topN=1)

    Z_assignment = model.Z_assignment
    A_assignment = model.A_assignment
    theta = model.theta
    phi = model.phi

    with open('WardNJU_Z_assignment_num_topics=' + str(flags.num_topics) + '.json', 'wb') as f:
        pickle.dump(Z_assignment, f)

    with open('WardNJU_Z_assignment_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        Z_assignment = pickle.load(f)

    with open('WardNJU_Z_assignment_num_topics=' + str(flags.num_topics) + '.txt', "w") as f:
        n = f.write(str(Z_assignment))


    with open('WardNJU_A_assignment_num_topics=' + str(flags.num_topics) + '.json', 'wb') as f:
        pickle.dump(A_assignment, f)

    with open('WardNJU_A_assignment_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        A_assignment = pickle.load(f)

    with open('WardNJU_A_assignment_num_topics=' + str(flags.num_topics) + '.txt', "w") as f:
        n = f.write(str(A_assignment))


    with open('WardNJU_theta_num_topics=' + str(flags.num_topics) + '.json', 'wb') as f:
        pickle.dump(theta, f)

    with open('WardNJU_theta_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        theta = pickle.load(f)

    with open('WardNJU_theta_num_topics=' + str(flags.num_topics) + '.txt', "w") as f:
        n = f.write(str(theta))


    with open('WardNJU_phi_num_topics=' + str(flags.num_topics) + '.json', 'wb') as f:
        pickle.dump(phi, f)

    with open('WardNJU_phi_num_topics=' + str(flags.num_topics) + '.json', 'rb') as f:
        phi = pickle.load(f)

    with open('WardNJU_phi_num_topics=' + str(flags.num_topics) + '.txt', "w") as f:
        n = f.write(str(phi))