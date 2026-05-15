import sys
from math import isqrt

def solve():
    N = int(sys.stdin.readline())

    if N > 1:
        print(1)

    if N <= 2:
        return

    limit = N - 1
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0

    for i in range(2, isqrt(limit) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))

    for i in range(2, N):
        if sieve[i]:
            print(i)

solve()
