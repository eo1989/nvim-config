import numpy as np
import scipy.stats as st
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns

mpl.rcParams["figure.figsize"] = (10, 6)
plt.style.use(["vibrant"])


def univariate_normal(x, mu, variance):
    """

    Args:
        x (variable):
        mu (mean):
        variance ():

    Returns:

    """
    return (1.0 / np.sqrt(2 * np.pi * variance)) * np.exp(
        -((x - mu) ** 2) / (2 * variance)
    )

x = np.linspace(-4, 5, num=150)

# TODO: create a function to make all of this plt code less verbose & reusable!
plt.plot(x, univariate_normal(x, mu=0, variance=1), label="$N(0, 1)$")
plt.plot(x, univariate_normal(x, mu=0, variance=0.2), label="$N(0, 0.2)$")
plt.plot(x, univariate_normal(x, mu=2, variance=3), label="$N(2, 3)$")
plt.xlabel("$x$", fontsize=13)
plt.ylabel("Density: $p(x)$", fontsize=13)
plt.title("Univariate Normal Distribution")
plt.ylim([0, 1])
plt.xlim([-3, 5])
plt.legend(loc="best")
fig = plt.subplots_adjust(bottom=0.15)
plt.show()
