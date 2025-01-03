import matplotlib.pyplot as plt
import networkx as nx

def topics_per_author_read(file_name):
    """
    Make a dictionary from txt file
    """
    #sample line: ["'Baer'"]: [(4, 0.5755257259125403), (5, 0.3571996042432249), (3, 0.03692681114427046), (9, 0.030326159524861684)]
    author_topic_prob_list = []
    def parse(line):
        author, topics = line.split(':')
        author = author.strip('["\']')
        print('author:', author)
        topic_prob_tuples = topics.strip(' [()]').split('), (')
        for topic_prob in topic_prob_tuples:
            topic, prob = topic_prob.split(',')
            print('topic_prob:', topic_prob)
            print('topic:', topic)
            print('prob:', prob)
            if author != '':
                author_topic_prob = [str(author), str(topic), float(prob)]
                author_topic_prob_list.append(author_topic_prob)


    file = open(file_name, 'rt')
    lines = file.read().split('\n')
    for l in lines[0:]:
        if l != '':
            parse(l)
    print('author_topic_prob_list:', author_topic_prob_list)
    file.close()
    return author_topic_prob_list


def plot_weighted_graph(author_topic_prob_list):
    G = nx.Graph()
    #try:
    for author_topic_prob in author_topic_prob_list:
        G.add_edge(author_topic_prob[0], author_topic_prob[1], weight=author_topic_prob[2])
    #except:
       #continue

    e1 = [(u, v) for (u, v, d) in G.edges(data=True) if d["weight"] <= 0.1]
    e2 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.1 < d["weight"] <= 0.2]
    e3 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.2 < d["weight"] <= 0.3]
    e4 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.3 < d["weight"] <= 0.4]
    e5 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.4 < d["weight"] <= 0.5]
    e6 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.5 < d["weight"] <= 0.6]
    e7 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.6 < d["weight"] <= 0.7]
    e8 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.7 < d["weight"] <= 0.8]
    e9 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.8 < d["weight"] <= 0.9]
    e10 = [(u, v) for (u, v, d) in G.edges(data=True) if 0.9 < d["weight"]]

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
    plt.savefig('topics_per_author_num_topic=10.png')
    plt.show()




if __name__ == "__main__":
    author_topic_prob_list = topics_per_author_read(file_name='at_model_author_vecs_num_topics=10.txt')
    plot_weighted_graph(author_topic_prob_list)
