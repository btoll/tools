#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// gcc -o phi eulers_totient_function.c -lm

void prime_factors(int n, int* buf) {
    int i = 0;

    while ((n & 1) == 0) {
        buf[i++] = 2;
        n >>= 1;
    }

    for (int j = 3; j <= sqrt(n); j += 2)
        while (n % j == 0) {
            buf[i++] = j;
            n /= j;
        }

    if (n > 2) {
        buf[i++] = n;
        buf[i] = '\0';
    } else
        buf[i] = '\0';
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s [n]\n", argv[0]);
        exit(1);
    }

    int n = atoi(argv[1]);
    int buf[20];

    prime_factors(n, buf);

    int i = 0, c;
    int last = 0;

    while (buf[i] != '\0') {
        c = buf[i++];

        if (c != last)
            n *= 1.0 - (1.0 / (float) c);

        last = c;
    }

    printf("phi(%s) = %d\n", argv[1], n);
}

