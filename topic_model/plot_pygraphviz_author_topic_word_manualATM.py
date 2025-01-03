import pygraphviz as pgv
import argparse
from collections import defaultdict
import pickle
def topics_per_author_read(file_name, threshold_AT_prob, threshold_authors_per_topic):
    """
    Read and process topics-per-author dictionary from json file
    """
    #sample key-value dict entry: 'Kruis': [('0.526', 89), ('0.238', 34), ('0.103', 2), ('0.033', 0), ('0.030', 39), ('0.029', 65), ('0.014', 57)]
    author_set = set()
    topic_set = set()
    author_topic_prob_dict_with_topic_key = defaultdict(list)
    #with open('WardNJU_topics_per_author_num_topics=' + str(num_topics) + '.json', 'rb') as f:
    with open(file_name, 'rb') as f:
        authors = pickle.load(f)
    for author, list_of_prob_topic_tuples in authors.items():
        for prob_topic_tuple in list_of_prob_topic_tuples:
            prob = float(prob_topic_tuple[0])
            topic = prob_topic_tuple[1]
            print('prob:', prob)
            print('topic:', topic)
            if float(prob) > threshold_AT_prob: #threshold probability for the author-topic edge to be drawn
                topic_set.add(topic)
                author_topic_prob_dict_with_topic_key[str(topic)].append([str(author), str(topic), float(prob)])
        author_set.add(author)

    print('before pruning: author_topic_prob_dict_with_topic_key:', author_topic_prob_dict_with_topic_key)

    #Delete any authors outside the top 5 (probability) authors of each topic
    for topic, author_topic_prob_vals in author_topic_prob_dict_with_topic_key.items():
        len_author_topic_prob_vals = len(author_topic_prob_vals)
        print('len_author_topic_prob_vals:', len_author_topic_prob_vals)
        if len_author_topic_prob_vals > threshold_authors_per_topic:
            author_topic_prob_vals.sort(key=lambda x: x[2], reverse=True)
            author_topic_prob_dict_with_topic_key[str(topic)] = author_topic_prob_dict_with_topic_key[str(topic)][:int(threshold_authors_per_topic)]

    print('after pruning: author_topic_prob_dict_with_topic_key:', author_topic_prob_dict_with_topic_key)
    author_topic_prob_pruned = list(author_topic_prob_dict_with_topic_key.values())
    author_topic_prob_pruned = [item for sublist in author_topic_prob_pruned for item in sublist]
    print('author_topic_prob_pruned:', author_topic_prob_pruned)

    return author_topic_prob_pruned, author_set, topic_set


def words_per_topic_read(file_name):
    """
    Read and process words-per-topic dictionary from json file
    """
    #Sample key-value pair: 0: [('0.017', 'widersprechen'), ('0.017', 'zulassen'), ('0.012', 'konflikt'), ('0.012', 'gemeinsam'), ('0.012', 'verbieten'), ('0.011', 'firma'), ('0.010', 'sozial'), ('0.010', 'beeinträchtigen'), ('0.010', 'damalig'), ('0.010', 'würdigen')]
    topic_word_dict = {}
    with open(file_name, 'rb') as f:
        topics = pickle.load(f)

    for topic, list_of_prob_word_tuples in topics.items():
        topic_word_dict[topic] = []
        for prob_word_tuple in list_of_prob_word_tuples:
            prob = float(prob_word_tuple[0])
            word = prob_word_tuple[1]
            print('prob:', prob)
            print('word:', word)
            topic_word_dict[topic] += [str(word)]
        print('topic_word_dict[topic]:', topic_word_dict[topic])


    return topic_word_dict


def plot_weighted_graph(author_topic_prob_list, author_set, topic_set, topic_word_dict, num_topics, num_displayed_words):
    dot = pgv.AGraph(rankdir="LR") #choose left to right bipartite structure (default is top to bottom)

    for topic in topic_set:
        word1 = str(topic_word_dict[topic][0])
        word2 = str(topic_word_dict[topic][1])
        word3 = str(topic_word_dict[topic][2])
        word4 = str(topic_word_dict[topic][3])
        word5 = str(topic_word_dict[topic][4])
        word6 = str(topic_word_dict[topic][5])
        word7 = str(topic_word_dict[topic][6])
        word8 = str(topic_word_dict[topic][7])
        word9 = str(topic_word_dict[topic][8])
        word10 = str(topic_word_dict[topic][9])

        #print('topic_word_dict[topic]:', topic_word_dict[topic])
        if num_displayed_words == 10:
            dot.add_node(topic, label=" <f0> " + str(topic) + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3
                                      + " | <f4> " + word4 + " | <f5> " + word5 + " | <f6> " + word6 + " | <f7> " + word7
                         + " | <f8> " + word8 + " | <f9> " + word9 + " | <f10> " + word10, shape="record")
        elif num_displayed_words == 5:
            dot.add_node(topic, label=" <f0> " + str(topic) + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3
                                      + " | <f4> " + word4 + " | <f5> " + word5, shape="record")
        elif num_displayed_words == 3:
            dot.add_node(topic, label=" <f0> " + str(topic) + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3, shape="record")

    #for author in author_set:
    #    dot.add_node(author)

    for author_topic_prob in author_topic_prob_list:
        #dot.add_edge(str(author_topic_prob[0]), str(author_topic_prob[1]), penwidth=author_topic_prob[2])
        dot.add_edge(str(author_topic_prob[1]), str(author_topic_prob[0]), penwidth=author_topic_prob[2], label=str(author_topic_prob[2])[:4])#, weight=author_topic_prob[2])

    #dot.graph_attr["shape"] = record
    dot.write("author_topic_weighted_pygraphviz_file.dot")
    dot.layout(prog='dot')  # help the layout looks bipartite and not messy (two clear regions of authors and topics)
    dot.draw('manual_author_topic_weighted_pygraphviz_num_topics=' + str(num_topics) + '.png')
    dot.draw('manual_author_topic_weighted_pygraphviz_num_topics=' + str(num_topics) + '.pdf')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate graphviz from author-topic and topic-word distributions")

    parser.add_argument('--num_topics', type=int, default=100)
    parser.add_argument('--num_displayed_words', type=int, default=10)
    #Rationale for choosing threshold_authors_per_topic = 7: because the most crowded ground-truth domains
    #Wehr- und Ersatzdienstrecht, einschließlich Unterhaltssicherungsrecht (military) and Freiwillige Gerichtsbarkeit
    #(Senat II) with 7 judges
    parser.add_argument('--threshold_authors_per_topic', type=int, default=7)
    parser.add_argument('--threshold_AT_prob', type=float, default=0.1)
    flags = parser.parse_args()

    num_topics = str(flags.num_topics)
    author_topic_prob_pruned, author_set, topic_set = topics_per_author_read(file_name='WardNJU_topics_per_author_num_topics=' + str(num_topics) + '.json',
                                                                           threshold_AT_prob = flags.threshold_AT_prob,
                                                                           threshold_authors_per_topic = flags.threshold_authors_per_topic)
    topic_word_dict = words_per_topic_read(file_name='WardNJU_words_per_topic_num_topics=' + str(num_topics) + '.json')
    plot_weighted_graph(author_topic_prob_pruned, author_set, topic_set, topic_word_dict, num_topics, flags.num_displayed_words)