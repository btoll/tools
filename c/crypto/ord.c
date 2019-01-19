#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// Find the order of an element of a group G.
// Note that this is different from the order of a group.
//
// https://www.di-mgt.com.au/multiplicative-group-mod-p.html
// gcc -o ord ord.c -lm

double gcd(double a, double b) {
    double r = fmod(a, b);
    if (r == 0) return b;
    return gcd (b, r);
}

void main(int argc, char **argv) {
    if (argc < 3) {
        printf("Finds the order of an element in group |G|:\n\n");
        printf("\tbase^k mod m\n\n");
        printf("Usage: %s <base> <mod>\n", argv[0]);
        exit(1);
    }

    int g = atoi(argv[1]);
    double p = atoi(argv[2]);

    if (gcd(g, p) != 1) {
        printf("Error: %d and %.0f must be coprime.\n", g, p);
        exit(1);
    }

    double k = 1;
    double res = fmod(pow(g, k), p);

    printf("<%d> { %.0f ", g, res);

    while (res != 1) {
        res = fmod(pow(g, ++k), p);
        printf("%.0f ", res);
    }

    printf("}\nord(%d) = %.0f\n", g, k);
}

