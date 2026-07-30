# Petanca: Una bibliotèca SageMath per far de calculs dins lo semianèl
# dels sistèmas dinamics or, in English, a SageMath library for
# computing in the semiring of dynamical systems
# Copyright (C) 2026 Antonio E. Porreca, Rocco Ascone

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


from sage.numerical.mip import MIPSolverException


class Permutation(CombinatorialFreeModule.Element):

    def cycles(self):
        return sorted(term.leading_term().leading_monomial()
                      for term in self.terms())

    def is_cycle(self):
        return len(self) == 1 and self.leading_coefficient() == 1

    def size(self):
        return int(sum(multiplicity * length
                       for length, multiplicity in self.items()))

    def is_improper(self):
        return any(coeff < 0 for coeff in self.coefficients())

    def is_irreducible(self):
        return (self != PP(0) and self != PP(1) and
                self.factor() == Factorization([(self, 1)]))

    def is_prime(self):
        # https://doi.org/10.1016/j.tcs.2026.115879
        return False

    def sqrt(self, k=2):
        # https://doi.org/10.48550/arXiv.2604.04065
        if self.is_improper():
            raise NotImplementedError(
                f'unable to compute sqrt of {self}')
        root = PP(0)
        power = PP(0)
        while power.size() < self.size():
            root += min((self - power).cycles())
            power = root^k
        if power != self:
            return None
        return root

    def factor(self):
        if self == PP(0):
            raise ArithmeticError(
                'factorization of 0 is not defined')
        if self == PP(1):
            return Factorization([])
        if self.is_cycle():
            F = factor(self.size())
            return Factorization([(C[b^e], 1) for b, e in F])
        for m, n in _proper_divisor_pairs(self.size()):
            for A in PP.irreducibles_of_size(m):
                for B in PP.of_size(n):
                    if A * B == self:
                        return Factorization([(A, 1)]) * B.factor()
        return Factorization([(self, 1)])

    def minimal_polynomial(self, var='X'):
        # This loop will eventually halt
        for deg in NN:
            basis = PP.up_closure(self.cycles())
            dim = len(basis)
            nvars = deg + 1
            A = matrix(ZZ, dim, nvars)
            power = PP(1)
            for j in range(nvars):
                for i in range(dim):
                    k = basis[i].size()
                    A[i, j] = power.coefficient(k)
                power *= self
            kernel = A.right_kernel()
            if not kernel:
                continue
            coeffs = kernel.basis()[0]
            if coeffs[-1] < 0:
                coeffs *= -1
            R.<X> = ZZ[var]
            return R.sum(coeffs[i] * X^i
                         for i in range(nvars))


class Permutations(CombinatorialFreeModule):

    Element = Permutation

    def __init__(self):
        CombinatorialFreeModule.__init__(
            self, ZZ, PositiveIntegers(), prefix='C',
            category=Category.join((AlgebrasWithBasis(ZZ),
                                    CommutativeRings())))

    def product_on_basis(self, m, n):
        return gcd(m, n) * C[lcm(m, n)]

    def one_basis(self):
        return 1

    def _repr_(self):
        return '(Semi)ring of Permutations'

    def __iter__(self):
        return (A for size in NN
                for A in PP.of_size(size))

    def is_field(self):
        return False

    def is_integral_domain(self):
        return False

    @staticmethod
    def irreducibles():
        return (A for A in PP
                if A.is_irreducible())

    @staticmethod
    def of_size(size):
        return (PP.sum(C[n] for n in partition)
                for partition in Partitions(size))

    @staticmethod
    def irreducibles_of_size(size):
        return (A for A in PP.of_size(size)
                if A.is_irreducible())

    @staticmethod
    def up_closure(generators):
        return sorted(set(PP.prod(S).leading_monomial()
                          for S in powerset(generators)))

    @staticmethod
    def down_closure(generators):
        return sorted(set(div for gen in generators
                          for term in gen.terms()
                          for cycle in term.cycles()
                          for div in divisors(cycle)))

    def _roots_univariate_polynomial(self, P, *args, **kwargs):
        # Only returns proper roots
        if _is_improper_polynomial(P):
            raise NotImplementedError
        cycle_len = lambda i: i
        cardinality = PP.module_morphism(cycle_len, codomain=ZZ)
        q = P.map_coefficients(cardinality)
        roots = q.roots(multiplicities=False)
        return [A for size in roots
                for A in PP.of_size(size)
                if P(A) == 0]

    @staticmethod
    def solve_linear(P):
        if P.degree() > 1 or _is_improper_polynomial(P):
            raise NotImplementedError(
                'root finding for this polynomial not implemented')
        cycles = _polynomial_cycles(P)
        down = PP.down_closure(cycles)
        basis = PP.up_closure(down)
        dim = len(basis)
        vars = P.variables()
        nvars = P.nvariables()
        M = matrix(ZZ, dim, dim * nvars)
        for k in range(nvars):
            for j in range(dim):
                A = (P.coefficient(vars[k])*basis[j]).constant_coefficient()
                for i in range(dim):
                    M[i, k*dim + j] = A.coefficient(basis[i].size())
        v = vector(ZZ, dim)
        B = -P.constant_coefficient()
        for i in range(dim):
            v[i] = B.coefficient(basis[i].size())
        milp = MixedIntegerLinearProgram()
        x = milp.new_variable(integer=True, nonnegative=True)
        milp.add_constraint(M * x == v)
        try:
            milp.solve()
        except MIPSolverException:
            return None
        sol = vector(milp.get_values(x, convert=ZZ, tolerance=1e-3))
        return tuple(PP.sum(basis[j] * sol[k*dim + j]
                            for j in range(dim))
                     for k in range(nvars))


def _proper_divisor_pairs(n):
    return ((d, n // d)
             for d in range(2, isqrt(n) + 1)
             if n % d == 0)


def _polynomial_cycles(P):
    return sorted(cycle for A in P.coefficients()
                  for cycle in A.cycles())


def _is_improper_polynomial(P):
    return any(A.is_improper() and (-A).is_improper()
               for A in P.coefficients())


# Constants

PP = Permutations()
C = PP.basis()
_R.<X> = PP[]


# Code for pseudo-injective polynomials, under development

from sage.functions.log import logb


def _root_pseudo_injective(self, P):
    # https://doi.org/10.48550/arXiv.2604.04065
    B = -P.constant_coefficient()
    P += B
    X = PP(0)
    seed = _seed(P)
    while P(X) < B:
        X += C[_anti_lcm(seed, B - P(X))]
    if P(X) != B:
        return None
    return X


def _is_pseudo_injective(P):
    const_coeff = P.coefficients()[0]
    nonconst_coeffs = P.coefficients()[1:]
    if const_coeff > 0 or any(PP(coeff).is_improper()
                              for coeff in nonconst_coeffs):
        return False
    cycles = _polynomial_cycles(P)
    seed = _seed(P)
    return all(cycle.size() % seed == 0
               for cycle in cycles)


def _anti_lcm(a, b):
    if a not in NN:
        a = min(a.cycles()).size()
    if b not in NN:
        b = min(b.cycles()).size()
    if b % a != 0:
        raise ValueError(f'{a} does not divide {b}')
    k = ceil(logb(b, 2))
    return gcd(int(b/a)^k, b)


def _seed(P):
    cycles = _polynomial_cycles(P)
    return cycles[0].size()
