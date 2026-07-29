# Petanca (PErmutaTion ANalysis and COmputation) 🪩

Petanca es una bibliotèca SageMath per far de calculs dins lo semianèl dels sistèmas dinamics or, in English, a [SageMath](https://www.sagemath.org) library for computing in the [semiring of dynamical systems](https://doi.org/10.1007/978-3-319-99813-8_27).
The name is pronounced [peˈtaŋkɔ], so the acronym is phonetically correct.

At the moment, only permutations (bijective dynamical systems) are being implemented, since they are simpler and seem to behave way nicer algebraically.
Hopefully, one day non-bijective ones will come too.


## License

In order to promote open research and teaching, Petanca is distributed under the [GNU AGPL](https://www.gnu.org/licenses/agpl-3.0.en.html) license.


## Installation

You can use `from petanca import *` in SageMath from the same directory where the file `petanca.py` is located.
(In case you need to know, this file is obtained with `sage --preparse petanca.sage; mv petanca.sage.py petanca.py`.)


## Basic usage

A permutation is represented as a sum of cycles with their multiplicity.
A cycle of length $n$ (usually denoted $C_n$) is represented by `C[n]` here:

```sage
sage: C[3] + 2*C[5] + C[7] + 1
C[1] + C[3] + 2*C[5] + C[7]
```

As you can see, `1` is currently displayed as `C[1]`, but both notations can be used in input.

The semiring operations of sum and product are available, as well as integer exponentiation:

```sage
sage: C[3] * C[6]
3*C[6]
sage: C[3] * C[7]
C[21]
sage: (C[2] + C[3])^5
16*C[2] + 81*C[3] + 475*C[6]
```

For technical reasons related to the SageMath library (but also because it seems practical, at least at the moment), the permutation semiring `PP` (representing the symbol $\mathbb{P}$) is currently implemented as the _ring_ $\mathbb{P}[-1]$, i.e., additive inverses also exist. 
This allows one to create improper dynamical systems like `C[2] - 1`; if you need to check if a dynamical system is improper, an aptly named method is available:

```sage
sage: C[3].is_improper()
False
sage: (C[3] - C[2]).is_improper()
True
```

Furthermore, be warned that, while $\mathbb{P}$ is an integral semidomain, $\mathbb{P}[-1]$ is _not_ an integral domain (i.e., there exist nontrivial zero divisors):

```sage
sage: (C[2] - 2) * C[2]
0
```

The following methods and functions should be more or less self-explanatory:

```sage
sage: (C[2] + 3*C[3]).cycles()
[C[2], C[3]]
sage: C[2].is_cycle()
True
sage: (C[2] + C[3]).is_cycle()
False
sage: (C[2] + C[3]).size()
5
sage: (C[2] + C[3]).is_irreducible()
True
sage: (C[2] * C[3]).is_irreducible()
False
sage: (C[2] + C[3]).is_prime()
False
sage: factor(C[2] * C[3] * (C[4] + 1))
(C[1] + C[4]) * C[2] * C[3]
sage: list(factor(C[2] * C[3] * (C[4] + 1)))
[(C[1] + C[4], 1), (C[2], 1), (C[3], 1)]
sage: sqrt((C[2] + C[3])^2)
C[2] + C[3]
sqrt((C[3] + 2*C[7])^3, 3)
C[3] + 2*C[7]
```

## The name of the game

The name of the library reflects the fact that the semiring of dynamical systems was first defined as such in Nice in 2015, where [the first PhD thesis](https://theses.fr/2022COAZ4062) on the topic was later written, and a lot of people working on this topic are, as of 2026, either in Marseille (where [the second PhD thesis](https://theses.fr/s373308) was written) or in Nice.
These two cities belong to region where the game of [pétanque](https://en.wikipedia.org/wiki/Pétanque) was developed and [lenga d’òc](https://en.wikipedia.org/wiki/Occitan_language) (specifically the Provençal dialect) is traditionally spoken.
“Petanca” is, of course, “pétanque” in lenga d’òc.
Furthermore, bijective dynamical systems, when they are depicted as graphs (i.e., as disjoint unions of cycles), remind one of the developers of this library of pétanque boules.


## AI statement

This software was written by human beings without any generative AI tools.
