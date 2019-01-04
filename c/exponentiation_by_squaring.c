#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// gcc -o basex exponentiation_by_squaring.c -lm

// bc <<< "(((((2^1)^2)^2)^2)^2)"
// 65536

void reverse(char *s) {
    int c, i, j;

    // Let's pretend there's no strlen function.
    for (j = 0; s[j] != '\0'; j++)
        ;

    for (i = 0, j--; i < j; i++, j--)
        c = s[i], s[i] = s[j], s[j] = c;
}

void getbits(int exp, char* buf) {
    int n = exp;
    int i = 0;
    int maxbits = (int) log2(exp);

    while (i <= maxbits) {
        int bit = n & 1;

        buf[i++] =
            bit == 0 ? '0' : '1';

        n /= 2;
    }

    buf[i] = '\0';
    reverse(buf);
}

void main(int argc, char **argv) {
    if (argc < 3) {
        printf("[ERROR] Not enough args: %s [base] [exp]\n", argv[0]);
        exit(1);
    }

    int base = atoi(argv[1]);
    char buf[32];

    getbits(atoi(argv[2]), buf);

    double res = 1;
    int i = 0;

    while (buf[i] != '\0') {
        res *= res;

        if (buf[i++] == '1')
            res *= base;
    }

    printf("%.0f\n", res);
}

