#include <stdlib.h>
#include <stdio.h>

// gcc -o gcd euclidean_algorithm.c

int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}

void main(int argc, char **argv) {
    if (argc < 3) {
        printf("[ERROR] Not enough args: %s [a] [b]\n", argv[0]);
        exit(1);
    }

    printf("%d\n", gcd(atoi(argv[1]), atoi(argv[2])));
}

