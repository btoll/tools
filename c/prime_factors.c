#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// gcc -o prime_factors prime_factors.c -lm

// The first two blocks handle composite numbers.
// The last condition takes care of any (prime) numbers
// that were not able to be reduced to 1 by the
// preceding blocks.

void prime_factors(int n) {
    // If the number is even, reduce it until it's odd.
    while (n % 2 == 0) {
        printf("%d ", 2);
        n /= 2;
    }

    // Now the number is guaranteed to be odd.
    for (int i = 3; i <= sqrt(n); i += 2)
        while (n % i == 0) {
            printf("%d ", i);
            n /= i;
        }

    // Handle a prime number > 2.
    if (n > 2)
        printf("%d", n);

    printf("\n");
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("[ERROR] Not enough args: %s [n]\n", argv[0]);
        exit(1);
    }

    prime_factors(atoi(argv[1]));
}

