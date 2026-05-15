# suplerplay21 — Problem 1 Solution

## Approach

Sieve of Eratosthenes. Marks composites in O(N log log N), then prints `1` followed by all unmarked indices (primes) less than N.

## Code

```go
package main

import "fmt"

func main() {
	var limit int
	fmt.Scanf("%d", &limit)

	nonPrimeList := make([]bool, limit)
	nonPrimeList[0] = true

	if limit == 1 {
		return
	}

	nonPrimeList[1] = true

	for i := 2; i*i < limit; i++ {
		if !nonPrimeList[i] {
			for j := i * i; j < limit; j += i {
				nonPrimeList[j] = true
			}
		}
	}

	fmt.Println(1)

	for i, v := range nonPrimeList {
		if !v {
			fmt.Println(i)
		}
	}
}
```

## How to Run

**Requirements:** Go 1.18+

```bash
# Compile
go build -o solution solution.go

# Run (enter N when prompted)
echo "100" | ./solution

# Windows
go build -o solution.exe solution.go
echo 100 | solution.exe
```

## Re-evaluate

From the `problems/problem-1/` directory:

```bash
# Windows
.\evaluate.exe "go run submissions\suplerplay21\solution.go" submissions\suplerplay21\results.md

# macOS
./evaluate "go run submissions/suplerplay21/solution.go" submissions/suplerplay21/results.md

# Linux
./evaluate-linux-amd64 "go run submissions/suplerplay21/solution.go" submissions/suplerplay21/results.md
```

## Score

**100 / 100** — all 10 test cases passed.
