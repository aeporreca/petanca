# Petanca (PErmutaTion ANalysis and COmputation) 🪩

Petanca es una bibliotèca SageMath per far de calculs dins lo semianèl dels sistèmas dinamics or, in English, a [SageMath](https://www.sagemath.org) library for computing in the [semiring of dynamical systems](https://doi.org/10.1007/978-3-319-99813-8_27).
The name is pronounced [peˈtaŋkɔ], so the acronym is phonetically valid.

At the moment, only permutations (bijective dynamical systems) are being implemented, since they are simpler and seem to behave way nicer algebraically.
Hopefully, one day non-bijective ones will come too.


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

sage: sqrt((C[2] + C[3])^2)
C[2] + C[3]

sage: sqrt((C[3] + 2*C[7])^3, 3)
C[3] + 2*C[7]
```

The `factor` function computes one (among the many possible) factorisations of a permutation:

```sage
sage: factor(C[2]^2 * C[3] * (C[4] + 1))
(C[1] + C[4]) * C[2]^2 * C[3]

sage: list(factor(C[2]^2 * C[3] * (C[4] + 1)))
[(C[1] + C[4], 1), (C[2], 2), (C[3], 1)]
```

Furthermore, the elements of `PP` can be enumerated in several ways:

```sage
sage: list(PP.of_size(4))
[C[4], C[1] + C[3], 2*C[2], 2*C[1] + C[2], 4*C[1]]

sage: list(PP.irreducibles_of_size(4))
[C[4], C[1] + C[3], 2*C[1] + C[2]]
```

The whole set (resp., the set of irreducibles) can be enumerated with `for A in PP` (resp., `for A in PP.irreducibles()`).


## Polynomials

You can also define polynomials over `PP`:

```sage
sage: C[4]*X^3 + 3*C[2]*X + C[7]
C[4]*X^3 + 3*C[2]*X + C[7]

sage: (X + C[3])*(X + C[7])
C[1]*X^2 + (C[3] + C[7])*X + C[21]
```

The variable `X` is predefined, but if you need more you can create them:

```sage
sage: R.<Y> = PP[]

sage: C[7]*Y^2 + C[3]*Y + 5
C[7]*Y^2 + C[3]*Y + 5*C[1]
```

You can find the minimal polynomial of a permutation `A` over the integers `ZZ` (i.e., the monic polynomial with coefficients in $\mathbb{Z}$ of minimum degree having `A` as a root):

```sage
sage: minimal_polynomial(C[2])
x^2 - 2*x
sage: minimal_polynomial(C[2] + C[3])
x^4 - 10*x^3 + 31*x^2 - 30*x
```

And you can find all roots of univariate polynomials:

```sage
sage: (X^2 - 5*X).roots()
[C[5], 5*C[1], 0]

sage: minimal_polynomial(C[2] + C[3]).roots(ring=PP)
[C[5], C[2] + C[3], 2*C[1] + C[3], 3*C[1] + C[2], 5*C[1], C[3], 3*C[1], C[2], 2*C[1], 0]
```


## Coming soon 🚧

- Solving multivariate linear equations


## The name of the game

The name of the library reflects the fact that the semiring of dynamical systems was first defined as such in Nice in 2015, where [the first PhD thesis](https://theses.fr/2022COAZ4062) on the topic was later written, and a lot of people working on this topic are, as of 2026, either in Marseille (where [the second PhD thesis](https://theses.fr/s373308) was written) or in Nice.
These two cities belong to region where the game of [pétanque](https://en.wikipedia.org/wiki/Pétanque) was developed and [lenga d’òc](https://en.wikipedia.org/wiki/Occitan_language) (specifically the Provençal dialect) is traditionally spoken.
“Petanca” is, of course, “pétanque” in lenga d’òc.
Furthermore, bijective dynamical systems, when they are depicted as graphs (i.e., as disjoint unions of cycles), remind one of the developers of this library of pétanque boules.


## AI statement

This software was written by human beings without any generative AI tools.


## License

In order to promote open research, Petanca is distributed under the [GNU AGPL](https://www.gnu.org/licenses/agpl-3.0.en.html) license.


## Credits

The Petanca software is copyright © 2026 by [Antonio E. Porreca](https://aeporreca.org) and [Rocco Ascone](https://roccoasc1.github.io).
The development has been partly supported by the French ANR project ANR-24-CE48-7504 [ALARICE](https://alarice.lis-lab.fr) and the EU HORIZON-MSCA-2022-SE-01
project 101131549 [ACANCOS](https://acancos.units.it).
