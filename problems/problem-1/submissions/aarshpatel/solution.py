import sys


def is_prime(k):
    if k < 2:
        return False
    i = 2
    while i * i <= k:
        if k % i == 0:
            return False
        i += 1
    return True


def main():
    data = sys.stdin.read().strip()
    if not data:
        return
    n = int(data)

    if n <= 1:
        return

    print(1)
    for k in range(2, n):
        if is_prime(k):
            print(k)


main()
