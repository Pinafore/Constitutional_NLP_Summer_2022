import pygraphviz as pgv
import argparse
from collections import defaultdict

def topics_per_author_read(file_name, threshold_AT_prob, threshold_authors_per_topic):
    """
    Make a dictionary from txt file
    """
    #sample line: ["'Baer'"]: [(4, 0.5755257259125403), (5, 0.3571996042432249), (3, 0.03692681114427046), (9, 0.030326159524861684)]
    #author_topic_prob_list = []
    author_set = set()
    topic_set = set()
    author_topic_prob_dict_with_topic_key = defaultdict(list)
    def parse(line):
        author, topics = line.split(':')
        author = author.strip('[]')
        #print('author:', author)
        topic_prob_tuples = topics.strip(' [()]').split('), (')
        for topic_prob in topic_prob_tuples:
            print('topic_prob:', topic_prob)
            if len(topic_prob) == 0:
                continue
            topic, prob = topic_prob.split(',')
            #print('topic_prob:', topic_prob)
            #print('topic:', topic)
            #print('prob:', prob)
            if float(prob) > threshold_AT_prob: #threshold probability for the author-topic edge to be drawn
                topic_set.add(topic)
                author_topic_prob_dict_with_topic_key[str(topic)].append([str(author), str(topic), float(prob)])
        author_set.add(author)


    file = open(file_name, 'rt')
    lines = file.read().split('\n')


    for l in lines[0:]:
        if l != '':
            parse(l)
    file.close()

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
    Make a dictionary from txt file
    """
    #sample line: 0: [('Satz', 0.011370244704464611), ('daten', 0.010311752447812753), ('Person', 0.007923058931208806), ('Übermittlung', 0.00676249471729218), ('Datum', 0.0066710452582965304), ('Bayvsg', 0.0053526809402379754), ('Gesetzgeber', 0.004417274580906245), ('Straftat', 0.004370149703342285), ('übermittlung', 0.004257321200079654), ('Bkag', 0.004242346269010679)]
    topic_word_dict = {}
    def parse(line):
        topic, words = line.split(':')
        topic_word_dict[topic] = []
        print('topic:', topic)
        word_prob_tuples = words.strip(' [()]').split('), (')
        for word_prob in word_prob_tuples:
            word, prob = word_prob.split(',')
            topic_word_dict[topic] += [word]
        print('topic_word_dict[topic]:', topic_word_dict[topic])


    file = open(file_name, 'rt')
    lines = file.read().split('\n')
    for l in lines[0:]:
        if l != '':
            parse(l)
    print('topic_word_dict:', topic_word_dict)
    file.close()
    return topic_word_dict


def plot_weighted_graph(author_topic_prob_list, author_set, topic_set, topic_word_dict, num_topics, num_displayed_words):
    dot = pgv.AGraph(rankdir="LR") #choose left to right bipartite structure (default is top to bottom)

    for topic in topic_set:
        word1 = topic_word_dict[topic][0]
        word2 = topic_word_dict[topic][1]
        word3 = topic_word_dict[topic][2]
        word4 = topic_word_dict[topic][3]
        word5 = topic_word_dict[topic][4]
        word6 = topic_word_dict[topic][5]
        word7 = topic_word_dict[topic][6]
        word8 = topic_word_dict[topic][7]
        word9 = topic_word_dict[topic][8]
        word10 = topic_word_dict[topic][9]
        if num_displayed_words == 10:
            dot.add_node(topic, label=" <f0> " + topic + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3
                                      + " | <f4> " + word4 + " | <f5> " + word5 + " | <f6> " + word6 + " | <f7> " + word7
                         + " | <f8> " + word8 + " | <f9> " + word9 + " | <f10> " + word10, shape="record")
        elif num_displayed_words == 5:
            dot.add_node(topic, label=" <f0> " + topic + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3
                                      + " | <f4> " + word4 + " | <f5> " + word5, shape="record")
        elif num_displayed_words == 3:
            dot.add_node(topic, label=" <f0> " + topic + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3, shape="record")

    #for author in author_set:
    #    dot.add_node(author)

    for author_topic_prob in author_topic_prob_list:
        #dot.add_edge(str(author_topic_prob[0]), str(author_topic_prob[1]), penwidth=author_topic_prob[2])
        dot.add_edge(str(author_topic_prob[1]), str(author_topic_prob[0]), penwidth=author_topic_prob[2], label=str(author_topic_prob[2])[:4])#, weight=author_topic_prob[2])

    #dot.graph_attr["shape"] = record
    dot.write("union_of_domains_topic_weighted_pygraphviz_file.dot")
    dot.layout(prog='dot')  # help the layout looks bipartite and not messy (two clear regions of authors and topics)
    dot.draw('union_of_domains_topic_weighted_pygraphviz_num_topics=' + str(num_topics) + '.png')
    dot.draw('union_of_domains_topic_weighted_pygraphviz_num_topics=' + str(num_topics) + '.pdf')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate graphviz from domain-topic and topic-word distributions")

    parser.add_argument('--num_topics', type=int, default=100)
    parser.add_argument('--num_displayed_words', type=int, default=10)
    #Rationale for choosing threshold_authors_per_topic = 7: because the most crowded ground-truth domains
    #Wehr- und Ersatzdienstrecht, einschließlich Unterhaltssicherungsrecht (military) and Freiwillige Gerichtsbarkeit
    #(Senat II) with 7 judges
    parser.add_argument('--threshold_authors_per_topic', type=int, default=7)
    parser.add_argument('--threshold_AT_prob', type=float, default=0.05) #trial and error (prob=0.05 threshold shows ~100 topics at num_topics=500)

    flags = parser.parse_args()

    num_topics = str(flags.num_topics)
    author_topic_prob_pruned, author_set, topic_set = topics_per_author_read(file_name='at_model_union_of_domains_author_vecs_num_topics=' + num_topics + '.txt',
                                                                           threshold_AT_prob = flags.threshold_AT_prob,
                                                                           threshold_authors_per_topic = flags.threshold_authors_per_topic)
    topic_word_dict = words_per_topic_read(file_name='at_model_union_of_domains_topics_num_topics=' + num_topics + '.txt')
    plot_weighted_graph(author_topic_prob_pruned, author_set, topic_set, topic_word_dict, num_topics, flags.num_displayed_words)