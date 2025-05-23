# This file was *autogenerated* from the file converse_theorem_info.sage

# Import all SageMath functionality
from sage.all_cmdline import *   # import sage library

# Define commonly used constants
_sage_const_0 = Integer(0)
_sage_const_1 = Integer(1)
_sage_const_2 = Integer(2)

# Import specific math tools and structures
from sage.all import is_prime, carmichael_lambda, GF, expand
from collections import defaultdict

# -------------------------------------------------------------------------
# Computes the highest power of l that divides N

def max_power(N, l):
    m = _sage_const_0
    while N % l == _sage_const_0:
        N //= l
        m += _sage_const_1
    return m

# -------------------------------------------------------------------------
# Groups elements in 'group' by their modulo class mod (q-1)/l^m

def partition_by_mod_q_minus_l_power(group, q, l):
    mod_dict = defaultdict(list)
    m = max_power(q - 1, l)
    mod_base = (q - 1) // (l**m)
    for i in group:
        mod_val = i % mod_base
        mod_dict[mod_val].append(i)
    subgroups = []
    for mod_val in sorted(mod_dict.keys()):
        subgroups.append(sorted(mod_dict[mod_val]))
    return subgroups

# -------------------------------------------------------------------------
# Converts a list of elements to a string in curly brace format

def list_to_curly_str(lst):
    return "{" + ",".join(str(x) for x in lst) + "}"

# -------------------------------------------------------------------------
# Converts a list of subgroups to curly string format for display

def subgroups_to_curly_str(subgroups):
    pieces = []
    for s in subgroups:
        pieces.append(list_to_curly_str(s))
    return ", ".join(pieces)

# -------------------------------------------------------------------------
# Class to generate and manipulate a Gauss sum table over GF(q^2)

class GaussSumTable:
    def __init__(self, q, additive_character_generator, multiplicative_character_generator, l):
        # Store basic parameters
        self.q = q
        self.l = l
        self.additive_character_generator = additive_character_generator
        self.multiplicative_character_generator = multiplicative_character_generator

        # Construct the finite field GF(q^2)
        self.finite_field = GF(q**_sage_const_2)
        self.generator = self.finite_field.gen()
        self.finite_field_elements = list(self.finite_field)

        # Extract multiplicative group (remove 0)
        self.finite_field_multiplicative_group = [x for x in self.finite_field_elements if x != _sage_const_0]

        # Determine number of theta indices
        N_theta = q**_sage_const_2 - _sage_const_1
        m_theta = max_power(N_theta, l)
        self.theta_range = N_theta // (l**m_theta)

        # Determine number of alpha indices
        N_alpha = q - _sage_const_1
        m_alpha = max_power(N_alpha, l)
        self.alpha_range = N_alpha // (l**m_alpha)

        # Initialize table with zeros
        self.table = [[_sage_const_0 for _ in range(self.alpha_range)] for _ in range(self.theta_range)]
        self.compute_gauss_sum_table()

    # Fill the entire Gauss sum table
    def compute_gauss_sum_table(self):
        for theta in range(self.theta_range):
            for alpha in range(self.alpha_range):
                self.table[theta][alpha] = self.compute_gauss_sum(theta, alpha)

    # Compute individual Gauss sum for given theta and alpha
    def compute_gauss_sum(self, theta, alpha):
        total = _sage_const_0
        for x in self.finite_field_multiplicative_group:
            additive_character_value = self.additive_character_generator**self.trace(x)
            theta_character_value = self.multiplicative_character_generator**(theta * self.log(x))
            alpha_character_value = self.multiplicative_character_generator**(alpha * self.get_norm_log(x))
            total += additive_character_value * theta_character_value * alpha_character_value
        return total

    # Compute norm log for the multiplicative character
    def get_norm_log(self, x):
        return (self.q + _sage_const_1) * self.log(x)

    # Compute log base generator (return 0 if x == 0)
    def log(self, x):
        return x.log(self.generator) if x != _sage_const_0 else _sage_const_0

    # Return the field trace of x
    def trace(self, x):
        return x.trace()

    # Identify all sets of identical rows in the Gauss sum table
    def find_identical_rows(self):
        n = len(self.table)
        visited = set()
        groups = []
        for i in range(n):
            if i in visited:
                continue
            group = [i]
            visited.add(i)
            for j in range(i + _sage_const_1, n):
                if j in visited:
                    continue
                match = True
                for k in range(len(self.table[i])):
                    if expand(self.table[i][k] - self.table[j][k]) != _sage_const_0:
                        match = False
                        break
                if match:
                    group.append(j)
                    visited.add(j)
            if len(group) > _sage_const_1:
                groups.append(group)
        return groups

    # Wrapper to return identical row groupings as counterexamples (if any)
    def find_counterexamples(self, l, q):
        counterexamples = []
        if (q - _sage_const_1) % l == _sage_const_0:
            identical_groups = self.find_identical_rows()
            if identical_groups:
                identical_groups = sorted(identical_groups, key=len, reverse=True)
                counterexamples.append((l, q, identical_groups))
        return counterexamples

# -------------------------------------------------------------------------
# Factory function to initialize GaussSumTable with constructed characters

def fL_bar_gauss_sum_table(q, l):
    if not is_prime(l):
        raise ValueError("l must be a prime number!")

    # Validate q is a prime power and extract p
    prime_power_result = q.is_prime_power(get_data=True)
    if prime_power_result[_sage_const_1] == _sage_const_0:
        raise ValueError("Expected a prime power!")
    p = prime_power_result[_sage_const_0]

    # Construct additive/multiplicative characters
    N = p * (q*q - _sage_const_1)
    m = max_power(N, l)
    N_prime = N // (l**m)
    c = carmichael_lambda(N_prime)
    F = GF(l**c)
    h = F.gen()

    return GaussSumTable(
        q,
        h**((l**c - _sage_const_1) // p),
        h**((p * (l**c - _sage_const_1)) // N_prime),
        l
    )

# -------------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------------
if __name__ == "__main__":
    # Read user input for prime l and prime power q
    l = Integer(input("Enter a prime ℓ: "))
    q = Integer(input("Enter a prime power q: "))

    # Generate Gauss sum table for the given l and q
    gauss_sum_table_object = fL_bar_gauss_sum_table(q, l)

    # Search for identical theta row groupings (counterexamples)
    counterexamples = gauss_sum_table_object.find_counterexamples(l, q)

    for l_val, q_val, identical_groups in counterexamples:
        print("-" * 100)
        print(
            f"{'Theta Groupings':<30}"
            f"{'Size':<8}"
            f"{'θ₁|𝔽*_q = θ₂|𝔽*_q':<40}"
            f"{'Size':<8}"
        )
        print("-" * 100)

        # Display each theta group and their modular subgroup partition
        for group in identical_groups:
            group_str = list_to_curly_str(group)
            group_size = len(group)
            mod_subgroups = partition_by_mod_q_minus_l_power(group, q, l)
            mod_subgroup_str = list_to_curly_str(sorted(sum(mod_subgroups, [])))
            largest_subgroup_size = max(len(s) for s in mod_subgroups)
            print(
                f"{group_str:<30}"
                f"{str(group_size):<8}"
                f"{mod_subgroup_str:<40}"
                f"{str(largest_subgroup_size):<8}"
            )
        print("-" * 100)
