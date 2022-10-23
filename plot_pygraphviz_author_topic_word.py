import graphviz
import pygraphviz as pgv


def topics_per_author_read(file_name):#author_topic_file_name, topic_word_file_name):
    """
    Make a dictionary from txt file
    """
    #sample line: ["'Baer'"]: [(4, 0.5755257259125403), (5, 0.3571996042432249), (3, 0.03692681114427046), (9, 0.030326159524861684)]
    author_topic_prob_list = []
    author_set = set()
    topic_set = set()
    def parse(line):
        author, topics = line.split(':')
        #author = author.strip('["\']')
        author = author.strip('[]')
        #print('author:', author)
        topic_prob_tuples = topics.strip(' [()]').split('), (')
        for topic_prob in topic_prob_tuples:
            topic, prob = topic_prob.split(',')
            #print('topic_prob:', topic_prob)
            #print('topic:', topic)
            #print('prob:', prob)
            if author != '':
                author_topic_prob = [str(author), str(topic), float(prob)]
                author_topic_prob_list.append(author_topic_prob)
                topic_set.add(topic)
        author_set.add(author)


    file = open(file_name, 'rt')
    lines = file.read().split('\n')
    for l in lines[0:]:
        if l != '':
            parse(l)
    #print('author_topic_prob_list:', author_topic_prob_list)
    file.close()
    return author_topic_prob_list, author_set, topic_set


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


def plot_weighted_graph(author_topic_prob_list, author_set, topic_set, topic_word_dict):
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

        dot.add_node(topic, label=" <f0> " + topic + " | <f1> " + word1 + " | <f2> " + word2 + " | <f3> " + word3
                                  + " | <f4> " + word4 + " | <f5> " + word5 + " | <f6> " + word6 + " | <f7> " + word7
                     + " | <f8> " + word8 + " | <f9> " + word9 + " | <f10> " + word10, shape="record")

    for author in author_set:
        dot.add_node(author)

    for author_topic_prob in author_topic_prob_list:
        #dot.add_edge(str(author_topic_prob[0]), str(author_topic_prob[1]), penwidth=author_topic_prob[2])
        dot.add_edge(str(author_topic_prob[1]), str(author_topic_prob[0]), penwidth=author_topic_prob[2])#, weight=author_topic_prob[2])

    #dot.graph_attr["shape"] = record
    dot.write("author_topic_weighted_pygraphviz_file.dot")
    dot.layout(prog='dot')  # help the layout looks bipartite and not messy (two clear regions of authors and topics)
    dot.draw('author_topic_weighted_pygraphviz.png')
    dot.draw('author_topic_weighted_pygraphviz.pdf')


if __name__ == "__main__":
    author_topic_prob_list, author_set, topic_set = topics_per_author_read(file_name='at_model_author_vecs_num_topics=10.txt')
    topic_word_dict = words_per_topic_read(file_name='at_model_topics_num_topics=10.txt')
    plot_weighted_graph(author_topic_prob_list, author_set, topic_set, topic_word_dict)