import numpy as np
import matplotlib.pyplot as plt
from scipy.special import gamma

n = np.linspace(1, 15, 2000)

colors = [
    '#e41a1c',  # red
    '#ff7f00',  # orange
    '#daa520',  # goldenrod
    '#4daf4a',  # green
    '#00ced1',  # dark turquoise
    '#377eb8',  # blue
    '#984ea3',  # purple
    '#a65628',  # brown
]

# --- Main graph: all 8 functions ---
fig1, ax1 = plt.subplots(figsize=(10, 7))

ax1.plot(n, np.ones_like(n),    color=colors[0], linewidth=2)
ax1.plot(n, np.log2(n),         color=colors[1], linewidth=2)
ax1.plot(n, np.sqrt(n),         color=colors[2], linewidth=2)
ax1.plot(n, n,                  color=colors[3], linewidth=2)
ax1.plot(n, n * np.log2(n),    color=colors[4], linewidth=2)
ax1.plot(n, n ** 2,             color=colors[5], linewidth=2)
ax1.plot(n, 2 ** n,             color=colors[6], linewidth=2)
ax1.plot(n, gamma(n + 1),       color=colors[7], linewidth=2)  # n! via gamma function

ax1.set_xlim(1, 15)
ax1.set_ylim(0, 100)
ax1.set_xlabel('n', fontsize=18)
ax1.set_ylabel('f(n)', fontsize=18)
ax1.tick_params(labelsize=14)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

fig1.tight_layout()
fig1.savefig('orders_of_growth.png', dpi=150)

# --- Zoom-in graph: just O(1) and O(log n) ---
fig2, ax2 = plt.subplots(figsize=(10, 7))

ax2.plot(n, np.ones_like(n), color=colors[0], linewidth=2)
ax2.plot(n, np.log2(n),      color=colors[1], linewidth=2)

ax2.set_xlim(1, 15)
ax2.set_ylim(0, 10)
ax2.set_xlabel('n', fontsize=18)
ax2.set_ylabel('f(n)', fontsize=18)
ax2.tick_params(labelsize=14)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

fig2.tight_layout()
fig2.savefig('orders_of_growth_const_log.png', dpi=150)

plt.show()

# --- Takeover graph: 100n vs 0.5n^2 ---
n3 = np.linspace(0, 250, 2000)

fig3, ax3 = plt.subplots(figsize=(10, 7))

ax3.plot(n3, 100 * n3,       color='#377eb8', linewidth=2)
ax3.plot(n3, 0.5 * n3 ** 2,  color='#e41a1c', linewidth=2)

ax3.set_xlim(0, 250)
ax3.set_ylim(0, 35000)
ax3.set_xlabel('n', fontsize=18)
ax3.set_ylabel('f(n)', fontsize=18)
ax3.tick_params(labelsize=14)
ax3.spines['top'].set_visible(False)
ax3.spines['right'].set_visible(False)

fig3.tight_layout()
fig3.savefig('orders_of_growth_takeover.png', dpi=150)
plt.show()
