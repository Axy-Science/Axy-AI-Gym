import sys

def solve():
    N = int(sys.stdin.readline())
    
    if N > 1:
        print(1)
    
    for num in range(2, N):
        is_prime = True
        for i in range(2, int(num**0.5) + 1):
            if num % i == 0:
                is_prime = False
                break
        if is_prime:
            print(num)

solve()