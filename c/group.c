#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// https://www.di-mgt.com.au/multiplicative-group-mod-p.html
// gcc -o group group.c -lm

float mod(float a, float N) {
    float ret = a - N * floor (a / N);

    printf("%f.1 mod %f.1 = %f.1 \n", a, N, ret);

    return ret;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        printf("Finds the order of an element in group |G|:\n\n");
        printf("\tn^e mod m\n\n");
        printf("Usage: %s <base> <mod>\n", argv[0]);
        exit(1);
    }

    int base = atoi(argv[1]);
    int p = atoi(argv[2]);
    int bound = p - 1;
    double b[p];

    for (int i = 1; i <= bound; i++) {
        b[i] = fmod(pow(base, i), p);
    }

    b[p] = '\0';
    printf("%p\n", b);

    return 0;
}

