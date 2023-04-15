import matplotlib.pyplot as plt

precision_1ref = [0.4406670942912123, 0.5493906350224503, 0.5971776779987171, 0.5899122807017544]
precision_2ref = [0.632312925170068, 0.6731292517006803, 0.6795918367346939, 0.6792517006802721]
num_topics = [10, 50, 100, 200]

plt.plot(num_topics, precision_1ref, marker="^")
plt.plot(num_topics, precision_2ref, marker="s")
plt.legend(["1-referee cases", "2-referees cases"], loc="lower right")
plt.title("AT model precision for cases with 1 or 2 semi-ground truth referees")
plt.xlabel("Number of topics")
plt.ylabel("Averaged Precision across cases")
plt.savefig("avg_precision_1ref_2ref.png")
plt.savefig("avg_precision_1ref_2ref.pdf")