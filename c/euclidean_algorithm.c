#include <stdlib.h>
#include <stdio.h>

// gcc -o gcd euclidean_algorithm.c

int gcd(int a, int b) {
    if (a % b == 0) return b;
    return gcd(b, a % b);
}

void main(int argc, char **argv) {
    if (argc < 3) {
        printf("[ERROR] Not enough args: %s [a] [b]\n", argv[0]);
        exit(1);
    }

    printf("%d\n", gcd(atoi(argv[1]), atoi(argv[2])));
}

