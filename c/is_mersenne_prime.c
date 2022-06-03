#include <stdlib.h>
#include <stdio.h>

int is_prime(int n) {
    if (n < 2) {
        return 0;
    }

    int h = n / 2 >> 0;

    for (int i = 2; i <= h; i++) {
        if (n % i == 0) return 0;
    }

    return 1;
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <number>\n", argv[0]);
        exit(1);
    }

    int n = atoi(argv[1]);

    is_prime(n) ?
        printf("%d\n", (n + 1 & n) == 0) :
        printf("%d\n", 0);
}

