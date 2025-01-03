import matplotlib.pyplot as plt
import networkx as nx

def words_per_topic_read(file_name):
    """
    Make a dictionary from txt file
    """
    #sample line: 0: [('Satz', 0.011370244704464611), ('daten', 0.010311752447812753), ('Person', 0.007923058931208806), ('Übermittlung', 0.00676249471729218), ('Datum', 0.0066710452582965304), ('Bayvsg', 0.0053526809402379754), ('Gesetzgeber', 0.004417274580906245), ('Straftat', 0.004370149703342285), ('übermittlung', 0.004257321200079654), ('Bkag', 0.004242346269010679)]
    topic_word_prob_list = []
    def parse(line):
        topic, words = line.split(':')
        print('topic:', topic)
        word_prob_tuples = words.strip(' [()]').split('), (')
        for word_prob in word_prob_tuples:
            word, prob = word_prob.split(',')
            if word != '':
                topic_word_prob = [str(topic), str(word), float(prob)]
                topic_word_prob_list.append(topic_word_prob)


    file = open(file_name, 'rt')
    lines = file.read().split('\n')
    for l in lines[0:]:
        if l != '':
            parse(l)
    print('topic_word_prob_list:', topic_word_prob_list)
    file.close()
    return topic_word_prob_list


def plot_weighted_graph(topic_word_prob_list):
    G = nx.Graph()
    #try:
    for topic_word_prob in topic_word_prob_list:
        G.add_edge(topic_word_prob[0], topic_word_prob[1], weight=topic_word_prob[2])
    #except:
       #continue



    e1 = [(u, v) for (u, v, d) in G.edges(data=True) if d["weight"] <= 0.001]
    e2 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.001 < d["weight"] <= 0.002]
    e3 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.002 < d["weight"] <= 0.003]
    e4 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.003 < d["weight"] <= 0.004]
    e5 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.004 < d["weight"] <= 0.005]
    e6 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.005 < d["weight"] <= 0.006]
    e7 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.006 < d["weight"] <= 0.007]
    e8 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.007 < d["weight"] <= 0.008]
    e9 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.008 < d["weight"] <= 0.009]
    e10 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.009 < d["weight"]]

    pos = nx.spring_layout(G, seed=7)
    nx.draw_networkx_nodes(G, pos, node_size=500)

    unit_width = 0.2
    nx.draw_networkx_edges(G, pos, edgelist=e1, width=1*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e2, width=2*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e3, width=3*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e4, width=4*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e5, width=5*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e6, width=6*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e7, width=7*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e8, width=8*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e9, width=9*unit_width)
    nx.draw_networkx_edges(G, pos, edgelist=e10, width=10*unit_width)

    # node labels
    nx.draw_networkx_labels(G, pos, font_size=5, font_family="sans-serif")
    # edge weight labels
    #edge_labels = nx.get_edge_attributes(G, "weight")
    #nx.draw_networkx_edge_labels(G, pos, edge_labels)

    ax = plt.gca()
    #ax.margins(0.08)
    plt.axis("off")
    plt.tight_layout()
    plt.savefig('at_words_per_topic_num_topic=10.png')
    #plt.show()




if __name__ == "__main__":
    topic_word_prob_list = words_per_topic_read(file_name='at_model_topics_num_topics=10.txt')
    plot_weighted_graph(topic_word_prob_list)