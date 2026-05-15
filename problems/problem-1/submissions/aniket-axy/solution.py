import sys
from math import isqrt
from itertools import compress


def main():
    data = sys.stdin.buffer.read().strip()
    if not data:
        return
    n = int(data)
    write = sys.stdout.write

    if n <= 1:
        return
    write("1\n")
    if n <= 2:
        return
    write("2\n")
    if n <= 3:
        return

    # Odd-only sieve: index i represents number 2*i + 1.
    size = (n + 1) // 2
    sieve = bytearray(b"\x01") * size
    sieve[0] = 0  # represents 1, not prime in the sieve sense

    limit = isqrt(n - 1)
    for i in range(1, (limit - 1) // 2 + 1):
        if sieve[i]:
            p = 2 * i + 1
            start = (p * p - 1) // 2
            sieve[start::p] = bytearray(len(sieve[start::p]))

    # Exclude trailing slot if it represents n (when n is odd).
    max_idx = size if n % 2 == 0 else size - 1

    primes = compress(range(1, max_idx), sieve[1:max_idx])
    sys.stdout.write("\n".join(str(2 * i + 1) for i in primes))
    sys.stdout.write("\n")


main()
