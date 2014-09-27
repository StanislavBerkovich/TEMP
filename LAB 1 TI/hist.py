import numpy as np
import matplotlib.pyplot as plt

#data
votes = [0, 4, 0, 1, 0, 1, 1, 1, 1, 1, 4, 4, 4, 4, 3, 4, 1, 0, 1, 4, 1, 4, 1, 1, 0, 4, 4, 0, 0, 0, 0, 0, 0, 3, 1, 1, 0, 1, 1, 3, 0, 0, 3, 1, 0, 1, 4, 0, 4, 1, 1, 1, 4, 1, 4, 0, 0, 1, 4, 0, 0, 4, 4, 1, 3, 0, 0, 0, 3, 0, 1, 4, 0, 1, 0, 1, 0, 0, 0, 1, 4, 3, 0, 0, 4, 0, 3, 4, 1, 0, 0, 4, 0, 0, 4, 4, 0, 1, 4, 1]
b = [-0.5, 0.5, 1.5, 2.5, 3.5, 4.5]

x = [10, 1e5, 1e10, 1e20, 1e40]
y =[0.1, 0.01, 0.001, 1e-8, 1e-20]


fig, (hist, gr) = plt.subplots(nrows=2)
#hist
hist.set_title('Sequence histogram')
hist.hist(votes, bins=b)
plt.xticks(np.arange(min(votes), max(votes)+1, 1.0))
plt.subplots_adjust(left=0.15)

#graph
gr.set_color_cycle('r')
gr.plot(x,y)
plt.xlabel('Sequence length')
plt.ylabel('Variation')
gr.set_title('Variation series')
gr.loglog(x,y, 'ro', basex=10, basey=10)

plt.show()
