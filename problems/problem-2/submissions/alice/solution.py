import sys
for line in sys.stdin:
    s = line.rstrip("\n")
    print("YES" if s == s[::-1] else "NO")
