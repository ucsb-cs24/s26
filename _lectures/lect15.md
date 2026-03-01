---
num: "lect15"
sequence: 15
desc: "Graph Search: Depth first traversal"
ready: true
pre-reading: "Savitch: 15.4"
pdfurl: /lectures/CS24_Graph_DFT.pdf
---



# Topics

* DFS with applications to leetcode problems
* Leetcode problem: https://leetcode.com/problems/keys-and-rooms/description/

# Visualizers

**Goal:** Step through the DFS algorithm on a small graph — trace the call stack, see how backtracking works, and understand why a single call to `exploreDFS(v)` is not enough for a disconnected graph. The third mode shows the outer loop in `DepthFirstSearch(G)` that handles disconnected components.

[Interactive DFS Visualizer]({{site.baseurl}}/assets/dfs_viz.html){:target="_blank"}

---

**Goal:** See DFS applied to a real problem you are implementing in PA03. The neural network is a directed graph where edges only go forward. To compute the nudge (delta) for each weight, you need values from nodes in the next layer — but there is no backward edge to follow. The recursive DFS naturally solves this: dive to the output first, compute the error there, then pass results back up the call stack. A contributions map (memoization) ensures each node is computed only once.

[Interactive Backpropagation Visualizer (PA03)]({{site.baseurl}}/assets/backprop_viz.html){:target="_blank"}

**What this visualizer does not show — questions for the curious student:**

- How is the error signal at the output node actually computed? What formula seeds the backward pass, and where does it come from?
- Why do these weight updates actually make predictions better? What guarantees that subtracting a delta moves the network in the right direction?
- Why does the learning rate matter? What goes wrong if it is too large or too small?
- Why average the deltas across a batch of training examples rather than updating after each one?

These videos answer those questions, visually and without heavy math:
- [3Blue1Brown — Gradient descent, how neural networks learn](https://youtu.be/IHZwWFHWa-w?si=_e4wkFW624ari842) (20 min)
- [3Blue1Brown — Backpropagation, intuitively](https://youtu.be/Ilg3gGewQ5U?si=ANRSwDucsfT5BFbN) (20 min)




