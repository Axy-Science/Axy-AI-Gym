import sys

def main():
    input_data = sys.stdin.read().strip()
    n = int(input_data)

    if n <= 1:
        return

    out = []

    # 1 is always output (problem title: "1 and Prime Numbers")
    if n > 1:
        out.append('1')

    # Sieve of Eratosthenes for primes < n
    limit = n
    sieve = bytearray([1]) * limit
    sieve[0] = 0
    sieve[1] = 0

    i = 2
    while i * i < limit:
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
        i += 1

    for p in range(2, limit):
        if sieve[p]:
            out.append(str(p))

    sys.stdout.write('\n'.join(out) + '\n' if out else '')

main()
