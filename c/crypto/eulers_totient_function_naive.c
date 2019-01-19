#include <stdio.h>
#include <stdlib.h>

// gcc -o naive eulers_totient_function_naive.c

int gcd(int a, int b) {
    if (a % b == 0) return b;
    return gcd(b, a % b);
}

int phi(int n) {
    int k = 1;

    for (int i = 2; i < n; ++i)
        if (gcd(n, i) == 1)
            ++k;

    return k;
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <n>\n", argv[0]);
        exit(1);
    }

    int n = atoi(argv[1]);
    printf("phi(%d) = %d\n", n, phi(n));
}

