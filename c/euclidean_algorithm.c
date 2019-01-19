#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// gcc -o gcd euclidean_algorithm.c -lm

double gcd(double a, double b) {
    double r = fmod(a, b);
    if (r == 0) return b;
    return gcd (b, r);
}

void main(int argc, char **argv) {
    if (argc < 3) {
        printf("[ERROR] Not enough args: %s [a] [b]\n", argv[0]);
        exit(1);
    }

    printf("%.0f\n", gcd(atoi(argv[1]), atoi(argv[2])));
}

