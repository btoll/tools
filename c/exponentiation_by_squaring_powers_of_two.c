#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// gcc -o exp2 exponentiation_by_squaring_powers_of_two.c -lm

// bc <<< "(((((2^1)^2)^2)^2)^2)"
// 65536

int is_power_of_two(int n) {
    return (n & n - 1) == 0;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        printf("[ERROR] Not enough args: %s [base] [exponent]\n", argv[0]);
        exit(1);
    }

    int exp = atoi(argv[2]);

    if (!is_power_of_two(exp)) {
        printf("[ERROR] Exponent `%d` is not a power of two, exiting.\n", exp);
        exit(1);
    }

    double res = atoi(argv[1]);
    int e = (int) log2(exp);    // We only need to loop until the log2 of the exponent since we're squaring!
    int i = 0;

    while (i < e) {
        res *= res;
        ++i;
    }

    // The results will always be whole numbers, so format as such.
    printf("%.0f\n", res);
    return 0;
}

