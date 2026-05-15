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
